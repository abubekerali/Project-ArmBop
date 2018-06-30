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
dest=read.csv('www/flight_dt_most_dest.csv')
origin=read.csv('www/flight_dt_most_origin.csv')
head(origin,10)
# Define UI for application that draws a histogram
origin <- dplyr::filter(origin, one > 0) %>% 
                    select(origin_city_name, origin_lon, origin_lat, one) %>% 
  mutate_at(vars(origin_lat, origin_lon, one),funs(as.numeric)) %>% na.omit

library(leaflet)
library(shiny)
library(shinydashboard)

# Choices for drop-downs
vars <- c(
  "Is SuperZIP?" = "superzip",
  "Centile score" = "centile",
  "College education" = "college",
  "Median income" = "income",
  "Population" = "adultpop"
)


shinyApp(
ui <- dashboardPage(
  dashboardHeader(title = 'United States Flight Map'),
  dashboardSidebar(
  	    tags$style(type = "text/css", "#MapPlot1 {height: calc(100vh - 40px) !important;}"),
    sliderInput(inputId = "flights", 
                label = "Flights Originating", 
                min = -50, max = 15000, value = 0, step = 500),
    tags$div(title = "This input has a tool tip",
             selectInput(inputId = "city", 
                label = "City", 
                choices = sort(unique(origin$origin_city_name))))
  ),
  dashboardBody(
    leafletOutput("MapPlot1")
  )
),
  
  server = function(input, output) {
    
    output$MapPlot1 <- renderLeaflet({
     leaflet() %>% 
       addProviderTiles("providers$Esri.NatGeoWorldMap") %>% 
        setView(lng = -100, lat = 50, zoom = 3)
    })
    
    observe({
      
      flights <- input$flights
      city <- input$city
      
      sites <- origin %>%
        filter(findInterval(origin$one, c(flights - 250, flights + 250)) == 1 &
                            origin$origin_city_name %in% city)
      
      m=leafletProxy("MapPlot1") %>% addTiles() 
      
      m %>% 
        addCircles(lng = origin$origin_lon,
                  lat = origin$origin_lat,
                  radius = origin$one)
	 
      m %>%
	      addMeasure(
		    position = "bottomleft",
		    primaryLengthUnit = "miles",
		    primaryAreaUnit = "sqmiles",
		    activeColor = "#3D535D",
		    completedColor = "#7D4479")

    })
  },
  options = list(height = 600)
)


