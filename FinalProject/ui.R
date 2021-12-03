#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        navlistPanel(
            tabPanel("About", uiOutput("aboutOne"), br(), uiOutput("aboutTwo"), br(), uiOutput("aboutThree"), img(src = "ImageOfTable.png", height = 90)),
            tabPanel("Data"),
            tabPanel("Data Exploration", plotOutput("diffPlot")),
            "Modeling",
            tabPanel("Modeling Info"),
            tabPanel("Model Fitting"),
            tabPanel("Prediction"),
        )
        
    )
))
