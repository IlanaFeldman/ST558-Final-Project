# for data exploration:
    # allow data filtering for both text and graph

library(shiny)
library(tidyverse)
library(tree)
library(caret)
library(ranger)
OnlineShoppers <- read_csv("online_shoppers_intention.csv")
OnlineShoppers$OperatingSystems <- as.factor(OnlineShoppers$OperatingSystems)
OnlineShoppers$Browser <- as.factor(OnlineShoppers$Browser)
OnlineShoppers$Region <- as.factor(OnlineShoppers$Region)
OnlineShoppers$TrafficType <- as.factor(OnlineShoppers$TrafficType)
OnlineShoppers$Revenue <- as.factor(OnlineShoppers$Revenue)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Behavior of Potential Online Shoppers"),

    # Sidebar with a slider input for number of bins

        navlistPanel(
            tabPanel("About", uiOutput("aboutOne"), br(), 
                     uiOutput("aboutTwo"), br(), 
                     uiOutput("aboutThree"), 
                     img(src = "ImageOfTable.png", height = 90)),
            
            
            tabPanel("Data", p("If you download the data, you may need to do so in browser mode."),
                     textOutput("tableInfo"),
                     downloadButton("downloadData", "Download the full dataset"),
                     checkboxGroupInput("variables", "Choose explanatory variables for the dataset", colnames(OnlineShoppers)[-18]),
                     
                     # Filter Range
                     selectInput("filterDataNumerics", "Choose a numeric variable to filter by.", colnames(OnlineShoppers[sapply(OnlineShoppers, is.numeric)])),
                     selectInput("filterDataBy", "Choose a type of range.", c("Less Than", "Equal To", "Greater Than")),
                     numericInput("filterDataNumber", "Choose a numerical boundary.", value = 1),
                     
                     # Action button + actual table
                     actionButton("updateTable", "Update Table"),
                     tableOutput("table")),
            
            
            tabPanel("Data Exploration", p("To start, choose either a textual or graphical output."),
                     selectInput("summaryType", "Type of Summary", c("Text", "Graph")),
                     
                     # Conditional Panels depending on the type of graph
                     conditionalPanel(condition = "input.summaryType == 'Text'",
                                      selectInput("textVariable", "Variable Summary Choice", colnames(OnlineShoppers)[-18]),
                                      verbatimTextOutput("textVariableSummary")),
                     
                     conditionalPanel(condition = "input.summaryType == 'Graph'",
                                      selectInput("graphType", "Choose a type of graph.", c("Box Plot", "Histogram / Bar Plot", "Scatterplot")),
                                      conditionalPanel(condition = "input.graphType == 'Box Plot'",
                                            selectInput("boxplotVariable", "Choose a numeric variable.", colnames(OnlineShoppers[sapply(OnlineShoppers, is.numeric)])),
                                            plotOutput("boxPlot")
                                      ),
                                      conditionalPanel(condition = "input.graphType == 'Histogram / Bar Plot'",
                                            selectInput("histbarplotVariable", "Choose a variable.", colnames(OnlineShoppers)),
                                            plotOutput("histbarPlot")
                                      ),
                                      conditionalPanel(condition = "input.graphType == 'Scatterplot'",
                                            selectInput("scatterVariableOne", "Choose the first variable.", colnames(OnlineShoppers)),
                                            selectInput("scatterVariableTwo", "Choose the second variable.", colnames(OnlineShoppers)),
                                            plotOutput("scatterPlot")
                                            )
                                     )
                     ),
            
            "Modeling",
            tabPanel("Modeling Info"),
            
            tabPanel("Model Fitting"),
            
            tabPanel("Prediction")
        )
        
    )
)
