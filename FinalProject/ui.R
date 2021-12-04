# subset rows for Data if there's time

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
                     actionButton("updateTable", "Update Table"),
                     tableOutput("table")),
            tabPanel("Data Exploration", p("Choose a variable to show a numerical summary of."),
                     selectInput("variableSummary", "Variable Summary Choice", colnames(OnlineShoppers)[-18]),
                     selectInput("summaryType", "Type of Summary", c("Text", "Graph")),
                     actionButton("createSummary", "Create Summary")
                     ),
            "Modeling",
            tabPanel("Modeling Info"),
            tabPanel("Model Fitting"),
            tabPanel("Prediction")
        )
        
    )
)
