#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

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


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    getData <- reactive({
        newData <- OnlineShoppers
    })
    
    getDataReduced <- reactive({
        newData <- OnlineShoppers[1:200,]
    })
    
    dataURL <- a("here.", href = "https://archive.ics.uci.edu/ml/datasets/Online+Shoppers+Purchasing+Intention+Dataset")
    output$aboutOne <- renderUI({
        tagList("This app is intended to be an exploratory app, which allows the user to easily and quickly work with the given online shopper data, which can be found",
        dataURL, "This includes summarization, modeling, predicting, and, of course, viewing the data.")
    })
    
    output$aboutTwo <- renderUI({
      tagList("The purpose of this data is to determine what trends exist in the behavior of potential shoppers on a certain shopping website.",
              "This data was collected over the course of one year for 12330 distinct sessions, each of which belonged to a different user of the website.",
              "Time spent across various types of pages, Google analytics trends, various attributes of the session such as browser used, and the month and whether it was a weekend were all recorded, as well as whether the session resulted in a transaction.",
              "The existance of a transaction, a logical value, appears to be the singular response variable for this data, although other trends can be observed.")  
    })
    
    output$aboutThree <- renderUI({
        HTML("Each subsequent tab is as follows: <br><ul><li> Data: Allows the user to observer, subset, and save the dataset. </li><li> Data Exploration: Allows the user to create custom summaries of the data. </li><li> Modeling: Allows the user to fit a model and create predictions. This is split into three tabs. </li></ul>")
    })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("OnlineShoppers.csv", sep ='')
        },
        content = function(file){
            write_csv(getData(), file)
        }
    )

    output$tableInfo <- renderText({
        newData <- getDataReduced()
        if(nrow(newData) == 200) {
            "The data is currently limited to 200 rows to avoid heavy strain."
        }
    })
    
    dataRows <- eventReactive(input$updateTable, {
        c(input$variables, "Revenue")
        })

    output$table <- renderTable({
        rows <- dataRows()
        reducedData <- getDataReduced()
        reducedData[rows]
    })
    

})
