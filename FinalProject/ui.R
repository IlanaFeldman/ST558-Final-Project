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
            tabPanel("About", 
                     uiOutput("aboutOne"), br(), 
                     uiOutput("aboutTwo"), br(), 
                     uiOutput("aboutThree"), 
                     img(src = "ImageOfTable.png", height = 90)),
            
            
            tabPanel("Data", 
                     p("If you download the data, you may need to do so in browser mode."),
                     textOutput("tableInfo"),
                     downloadButton("downloadData", "Download the full dataset."),
                     checkboxGroupInput("variables", "Choose explanatory variables for the dataset.", colnames(OnlineShoppers)[-18]),
                     
                     # Filter Range
                     selectInput("filterDataNumerics", "Choose a numeric variable to filter by.", colnames(OnlineShoppers[sapply(OnlineShoppers, is.numeric)])),
                     selectInput("filterDataBy", "Choose a type of range.", c("Greater Than", "Equal To", "Less Than")),
                     numericInput("filterDataNumber", "Choose a numerical boundary.", value = -1),
                     
                     # Action button + actual table
                     actionButton("updateTable", "Update Table"),
                     tableOutput("table")),
            
            
            tabPanel("Data Exploration", 
                     p("To start, choose either a textual or graphical output."),
                     selectInput("summaryType", "Type of Summary", c("Text", "Graph")),
                     
                     selectInput("filterGraphNumerics", "Choose a numeric variable to filter by.", colnames(OnlineShoppers[sapply(OnlineShoppers, is.numeric)])),
                     selectInput("filterGraphBy", "Choose a type of range.", c("Greater Than", "Equal To", "Less Than")),
                     numericInput("filterGraphNumber", "Choose a numerical boundary.", value = -1),
                     
                     # Conditional Panels depending on the type of graph
                     conditionalPanel(condition = "input.summaryType == 'Text'",
                                      selectInput("textVariable", "Choose a variable to summarize.", colnames(OnlineShoppers)[-18]),
                                      verbatimTextOutput("textVariableSummary")),
                     
                     conditionalPanel(condition = "input.summaryType == 'Graph'",
                                      selectInput("graphType", "Choose a type of graph.", c("Box Plot", "Histogram / Bar Plot", "Scatterplot")),
                                      conditionalPanel(condition = "input.graphType == 'Box Plot'",
                                            selectInput("boxplotVariable", "Choose a numeric variable for the graph.", colnames(OnlineShoppers[sapply(OnlineShoppers, is.numeric)])),
                                            plotOutput("boxPlot")
                                      ),
                                      conditionalPanel(condition = "input.graphType == 'Histogram / Bar Plot'",
                                            selectInput("histbarplotVariable", "Choose a variable for the graph.", colnames(OnlineShoppers)),
                                            plotOutput("histbarPlot")
                                      ),
                                      conditionalPanel(condition = "input.graphType == 'Scatterplot'",
                                            selectInput("scatterVariableOne", "Choose the first variable for the graph.", colnames(OnlineShoppers)),
                                            selectInput("scatterVariableTwo", "Choose the second variable for the graph.", colnames(OnlineShoppers)),
                                            plotOutput("scatterPlot")
                                            )
                                     )
                     ),
            
            "Modeling",
            tabPanel("Modeling Info", 
                     uiOutput("modelInfo")),
            
            tabPanel("Model Fitting", 
                     sliderInput("trainingSize", "Choose the proportion of data to train your model.", min = 0.01, max = 0.2, value = 0.1, step = 0.005),
                     checkboxGroupInput("modelVariables", "Choose explanatory variables for the models.", colnames(OnlineShoppers)[-18]),
                     actionButton("startFit", "Fit the models!"),
                     
                     # Outputs
                     verbatimTextOutput("linearModel"),
                     verbatimTextOutput("classTreeModel"),
                     plotOutput("classTreeGraph"),
                     verbatimTextOutput("randomForestModel"),
                     plotOutput("randomForestGraph"),
                     ),
            
            tabPanel("Prediction",
                     p("You can predict a response using a classification tree and the significant variables according to the full generalized linear model."),
                     numericInput("predictExitRates", "Choose a value for the Exit Rate (Recommended between 0 and 0.2).", value = 0),
                     numericInput("predictPageValues", "Choose a value for the Page Value (Recommended between 0 and 361.7637)", value = 0),
                     selectInput("predictTrafficType", "Choose a value for the Traffic Type factor.", 1:20),
                     actionButton("startPredict", "Predict!"),
                     verbatimTextOutput("prediction")
                     )
        )
        
    )
)
