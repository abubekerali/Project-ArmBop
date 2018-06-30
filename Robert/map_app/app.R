#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(leaflet)
library(shinydashboard)
library(shiny)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(leaflet.minicharts)

#setwd('/Users/rorr/PythonStuff/Project-ArmBop/Robert/map_app')
origin=read.csv('www/origin_map.csv')
origin$X=NULL
str(origin)
origin$type = 'origin'

destination=read.csv('www/dest_map.csv')
destination$X=NULL
str(destination)
destination$type = 'destination'

map_data=rbind(destination, origin)
str(map_data)

map_data <- dplyr::filter(map_data, flights.sum > 0) %>% mutate_at(vars(lat, lon, flights.sum, cancelled.counter, delay.counter, nas_delay.counter,carrier_delay.counter,weather_delay.counter,security_delay.counter,late_aircraft_delay.counter),funs(as.numeric)) %>% na.omit

map_data$cancelled.percent = map_data$cancelled.counter/map_data$flights.sum
map_data$delay.percent = map_data$delay.counter/map_data$flights.sum
map_data$nas_delay.percent = map_data$nas_delay.counter/map_data$flights.sum
map_data$carrier_delay.percent = map_data$carrier_delay.counter/map_data$flights.sum
map_data$weather_delay.percent = map_data$weather_delay.counter/map_data$flights.sum
map_data$security_delay.percent = map_data$security_delay.counter/map_data$flights.sum
map_data$delay.percent = map_data$delay.counter/map_data$flights.sum
map_data$late_aircraft_delay.percent = map_data$late_aircraft_delay.counter/map_data$flights.sum

map_data$not_cancelled.percent = 1- map_data$cancelled.counter/map_data$flights.sum
map_data$not_delay.percent = 1- map_data$delay.counter/map_data$flights.sum
map_data$not_nas_delay.percent = 1- map_data$nas_delay.counter/map_data$flights.sum
map_data$not_carrier_delay.percent = 1- map_data$carrier_delay.counter/map_data$flights.sum
map_data$not_weather_delay.percent = 1- map_data$weather_delay.counter/map_data$flights.sum
map_data$not_security_delay.percent = 1- map_data$security_delay.counter/map_data$flights.sum
map_data$not_delay.percent = 1- map_data$delay.counter/map_data$flights.sum
map_data$not_late_aircraft_delay.percent = 1- map_data$late_aircraft_delay.counter/map_data$flights.sum


# Define UI for application that draws a map

# Choices for drop-downs
vars <- c(
  "Canceled Flights" = "cancelled.percent",
  "Total Delays" = "delay.percent",
  "National Aviation System Delay" = "nas_delay.percent",
  "Carrier Delay" = "carrier_delay.percent",
  "Weather Delay" = "weather_delay.percent",
  "Security Delay" = "security_delay.percent",
  "Late Aircraft Delay" = "late_aircraft_delay.percent")

ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
  	tags$div(title = "This input has a tool tip"),
             selectInput(inputId = "type", 
                label = "Origin / Destination", 
                choices = unique(map_data$type), selected = "origin"),
             
  		    selectInput(inputId = "variable", 
                label = "Variable", 
                choices = vars)
),
  dashboardBody(
    tags$style(type = "text/css", "#MapPlot1 {height: calc(100vh - 80px) !important;}"),
    leafletOutput("MapPlot1")))
  
server = function(input, output) {
    output$MapPlot1 <- renderLeaflet({
     leaflet() %>% addProviderTiles("providers$Esri.NatGeoWorldMap") %>% 
    	setView(lng = -93.85, lat = 37.45, zoom = 4) })
     m=leafletProxy("MapPlot1") %>% addTiles()
	colors <- c("#4fc13c", "#cccccc")

     observe({
	      type <- input$type
	      city <- input$city
	      variable <- input$variable
	      
	pal <- colorNumeric("YlOrRd", domain = as.numeric(map_data[[variable]]))
	radius <- map_data[[variable]] / max(map_data$flights.sum) * 20000000
	
	m = m %>% clearShapes() %>% clearMarkers() %>%
        addCircleMarkers(lng = map_data$lon,
                  lat = map_data$lat,
                  radius = radius
      		 #,fillColor = ~pal(as.numeric(variable))
      		 )

      m %>% addMeasure(
		    position = "bottomleft",
		    primaryLengthUnit = "miles",
		    primaryAreaUnit = "sqmiles",
		    activeColor = "#3D535D",
		    completedColor = "#7D4479")
   
  })
}

shinyApp(ui=ui,server=server,  options = list(height = 600))

library(rsconnect)
rsconnect::deployApp('/Users/rorr/PythonStuff/Project-ArmBop/Robert/map_app')

