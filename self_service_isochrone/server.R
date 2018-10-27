library(shiny)
library(leaflet)
library(osrm)
library(rgdal)
library(sp)
library(sf)
library(viridis)

shinyServer(function(input, output) {
  
  isoCoords <- reactive({
    coords <- c(lat = input$lat,
                lon = input$lon)
    coords
  })
  isochrone <- eventReactive(input$submit, {
    isochrone <- osrmIsochrone(loc = c(isoCoords()[['lon']],
                                       isoCoords()[['lat']]),
                               breaks = as.numeric(input$driveTime),
                               res = 30) %>%
      st_as_sf()
    isochrone
  })
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers[['OpenStreetMap']])
  })
  observeEvent(input$submit , {
    steps <- sort(as.numeric(input$driveTime))
    isochrone <- cbind(steps = steps[isochrone()[['id']]], isochrone())
    pal <- colorFactor(viridis::plasma(nrow(isochrone), direction = -1), 
                       isochrone$steps)
    leafletProxy("map") %>%
      clearShapes() %>% 
      clearMarkers() %>%
      clearControls() %>%
      addPolygons(data = isochrone,
                  weight = .5, 
                  color = ~pal(steps)) %>%
      addLegend(data = isochrone,
                pal = pal, 
                values = ~steps,
                title = 'Drive Time (min.)') %>%
      addMarkers(lng = input$lon, input$lat) %>%
      setView(isoCoords()[['lon']], isoCoords()[['lat']], zoom = 9)
  })
  observe({
    leafletProxy("map") %>%
      clearTiles() %>%
      addProviderTiles(providers[[input$bgmap]])
  })
  output$dlIsochrone <- downloadHandler(
    filename = function() {
      paste0("drivetime_isochrone", input$shapeOutput)
    },
    content = function(file) {
      st_write(isochrone(), file)
    }
  )
  
})
