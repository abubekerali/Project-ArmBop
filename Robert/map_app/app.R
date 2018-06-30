#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# library(rsconnect)
# rsconnect::deployApp('/Users/rorr/PythonStuff/Project-ArmBop/Robert/map_app')

setwd('/Users/rorr/PythonStuff/Project-ArmBop/Robert/map_app')
origin=read.csv('www/origin_map.csv')
head(origin,10)
destination=read.csv('www/dest_map.csv')
head(origin,10)

# Define UI for application that draws a histogram
# origin <- dplyr::filter(origin, one > 0) %>% 
#                     select(origin_city_name, origin_lon, origin_lat, one) %>% 
#   mutate_at(vars(lat, lon, dest.sum, origin.sum),funs(as.numeric)) %>% na.omit

library(leaflet)
library(shiny)
library(shinydashboard)

# Choices for drop-downs
vars <- c(
  "Origin" = "origin.sum",
  "Destination" = "dest.sum"
)


ui <- dashboardPage(
  dashboardHeader(title = 'United States Flight Map'),
  dashboardSidebar(
  	selectInput("dataset", "Choose a dataset:", choices = c("Destination", "Origin")),
    uiOutput("var2"),
    sliderInput(inputId = "flights", 
                label = "Flights Originating", 
                min = -50, max = 15000, value = 0, step = 500)),
    # tags$div(title = "This input has a tool tip",
    #          selectInput(inputId = "city", 
    #             label = "City", 
    #             choices = sort(unique(origin$origin_city_name)
    #             			)))
  dashboardBody(
     tags$style(type = "text/css", "#MapPlot1 {height: calc(100vh - 40px) !important;}"),
  	leafletOutput("MapPlot1")
  )
)
  
server = function(input, output) {
 # Swithc Datasource
	dataSource <- reactive({switch(input$dataset,"Destination" = origin,"Origin" = destination)})
  # Dynamically create the selectInput
  output$var2 <- renderUI({selectInput("var", "Choose Variable",choices = names(dataSource()), selected = names (dataSource())[1])})
  my_subset_data <- reactive({        
    # Here check if the column names correspond to the dataset
    if(any(input$xvar %in% names(dataSource())) & any(input$yvar %in% names(dataSource())))
    {
      df <- subset(dataSource(), select = c(input$var, input$lat, input$lon, input$city))
      names(df) <- c("var","lat", 'lon', 'city')
      return(df)
    }
  })
    output$MapPlot1 <- renderLeaflet({
     leaflet() %>% 
       addProviderTiles("providers$Esri.NatGeoWorldMap") %>% 
        setView(lng = -100, lat = 50, zoom = 3)
    })
    
    observe({
       city <- input$city
      
      # sites <- origin %>%
      #   filter(findInterval(origin$one, c(flights - 250, flights + 250)) == 1 &
      #                       origin$origin_city_name %in% city)
    m <- my_subset_data()
    # Test for null as ggvis will evaluate this way earlier when the my_subset_data is NULL
    if(!is.null(m)){
      m=leafletProxy("MapPlot1") %>% addTiles() 
    }
      m %>% 
        addCircles(lng = lon,
                  lat = lat,
                  radius = var)
	 
      m %>%
	      addMeasure(
		    position = "bottomleft",
		    primaryLengthUnit = "miles",
		    primaryAreaUnit = "sqmiles",
		    activeColor = "#3D535D",
		    completedColor = "#7D4479")

    })
}

shinyApp(ui,server,  options = list(height = 600))

