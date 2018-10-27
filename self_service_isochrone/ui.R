library(shiny)
library(leaflet)
library(shinythemes)

shinyUI(fluidPage(theme = shinytheme('paper'),
                  headerPanel(title = "Drive Time Isochrone"),
                  sidebarLayout(
                    sidebarPanel(
                      tags$p("Powered by:"),
                      tags$a(href = 'http://project-osrm.org/', 
                             "Open Source Routing Machine"),
                      br(),
                      br(),
                      selectInput("bgmap", "Background Map",
                                  selected = leaflet::providers$OpenStreetMap,
                                  choices = setNames(providers,
                                                     gsub("\\.", " ", providers))
                      ),
                      numericInput("lat",
                                   "Latitude",
                                   41.2524,
                                   min = -90,
                                   max = 90),
                      numericInput("lon",
                                   "Longitude",
                                   -95.9980,
                                   min = -180,
                                   max = 180),
                      selectInput("driveTime",
                                  "Drive Time (min.)",
                                  seq(10, 60, 5),
                                  selected = seq(10, 60, 5),
                                  multiple = TRUE),
                      actionButton("submit", "Submit", 
                                   icon = icon("ok",
                                               lib = "glyphicon")),
                      br(),
                      br(),
                      selectInput("shapeOutput",
                                  "Select Output Type",
                                  c("Shapefile" = ".shp",
                                    "GeoJSON" = ".geojson"),
                                  selected = ".geojson"
                      ),
                      downloadButton("dlIsochrone", "Download")
                    ),
                    mainPanel(
                      leafletOutput("map", height = 600)
                    )
                  )        
))
