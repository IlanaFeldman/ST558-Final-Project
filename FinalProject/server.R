#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })
    
    output$diffPlot <- renderPlot({
        
        x2 <- c(1, 2, 3)
        y2 <- c(3, 4, 2)
        plot(x2, y2)
        
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
    
    
    
    output$coolText <- renderText({
        "Hello there! There is no reason to be alarmed."
    })
    
    output$coolTextTwo <- renderText({
        "Hello there! There is some reason to be alarmed."
    })
    
    output$coolTextThree <- renderText({
        "Hello there! There is much reason to be alarmed."
    })

})
