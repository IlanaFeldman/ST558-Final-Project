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
        if (input$filterDataBy == "Greater Than") {
          newData <- OnlineShoppers %>% filter(.data[[input$filterDataNumerics]] > .env$input$filterDataNumber)
        }
        else if (input$filterDataBy == "Equal To") {
          newData <- OnlineShoppers %>% filter(.data[[input$filterDataNumerics]] == .env$input$filterDataNumber)
        }
        else {
          newData <- OnlineShoppers %>% filter(.data[[input$filterDataNumerics]] < .env$input$filterDataNumber)
        }
        if (nrow(newData) > 200) {
          newData <- newData[1:200,]
        } else {newData <- newData}
      return(newData) # Worked without this/the previous line until I added some completely unrelated stuff???
    })
    
    getDataFiltered <- reactive({
      if (input$filterGraphBy == "Greater Than") {
        newData <- OnlineShoppers %>% filter(.data[[input$filterGraphNumerics]] > .env$input$filterGraphNumber)
      }
      else if (input$filterGraphBy == "Equal To") {
        newData <- OnlineShoppers %>% filter(.data[[input$filterGraphNumerics]] == .env$input$filterGraphNumber)
      }
      else {
        newData <- OnlineShoppers %>% filter(.data[[input$filterGraphNumerics]] < .env$input$filterGraphNumber)
      }
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
        list(c(input$variables, "Revenue"),
             getDataReduced()
        )
        })
    
    output$table <- renderTable({
        rows <- dataRows()[[1]]
        reducedData <- dataRows()[[2]]
        reducedData[rows]
    })
    
    output$textVariableSummary <- renderPrint({
      allData <- getDataFiltered()
      if (is.character(pull(OnlineShoppers[input$textVariable])) == FALSE) {
        summary(allData[input$textVariable])
      } else {
        table(allData[input$textVariable])
      }
    })
    
    output$boxPlot <- renderPlot({
      allData <- getDataFiltered()
      ggplot(allData, aes(.data[[input$boxplotVariable]])) + geom_boxplot()
      # Chose not to use geom_jitter since this actively makes the data less readable.
    })
    
    output$histbarPlot <- renderPlot({
      allData <- getDataFiltered()
      g <- ggplot(allData, aes(.data[[input$histbarplotVariable]]))
      if (is.numeric(pull(OnlineShoppers[input$histbarplotVariable])) == TRUE) {
        g + geom_histogram()
      } else {
        g + geom_bar()
      }
    })
    
    output$scatterPlot <- renderPlot({
      allData <- getDataFiltered()
      ggplot(allData, aes(x = .data[[input$scatterVariableOne]], y = .data[[input$scatterVariableTwo]])) + geom_point()
    })
    
    
    output$modelInfo <- renderUI({
      withMathJax(
        helpText('The Generalized Linear Model is an advanced form of the simple / multiple linear regression, which assumes the reponse variable can be most accurately expressed as a linear combination of the explanatory variables. In the generalized linear model, the response variable is taken as a function of this linear combination. In this particular case, since the Revenue variable is either TRUE or FALSE, our generalized linear model will calculate the probability of a transaction taking place. For example,
                 $$P(\\text{Successful Transaction}) = \\frac{B_0 + B_1x}{1 + e^{B_0 + B_1x}}$$
                 ...would be a binomial outcome modeled by an intercept term and one variable. This will always evaluate to a value between 0 and 1. While this type of model is very simple at its basics and is usable for predictions, it is much harder to interpret when there are many variables, and collinear variables can make the perceived significance of some variables misleading.'
        ),
        helpText('A Classification Tree is a relatively simple way of interpreting the data and making future predictions easy. Data is split into groups based on the values of their more significant variables, and a single prediction is made for each group. In order to make a prediction from this model, you simply answer a series of TRUE/FALSE questions to easily determine which group you are in. This method sacrifices prediction quality for interpretability, which is why the third method given exists...'
                 ),
        helpText('A Random Forest Model fixes many of the problems with classification trees. To start, a bootstrap sample is taken, allowing us to gain many classification trees from the same data, which we can average. Additionally, we will only include a subset of the predictors, instead of all of them, to avoid the potential issue where every tree is very similar due to a single powerful predictor. The downsides to this are that we lose a lot of interpretability due to merging together many different trees, and a random forest model also takes a lot more computing power. To make it usable on this app, I am using the ranger method instead of the rf method.'
                 )
      )
      
    })
    
    models <- eventReactive(input$startFit, {
      allData <- getData()
      set.seed(144)
      formula <- paste0(input$modelVariables, collapse = "+")
      shoppingIndex <- createDataPartition(OnlineShoppers$Revenue, p = input$trainingSize, list = FALSE)
      trainingData <- allData[shoppingIndex, ]
      testData <- allData[-shoppingIndex, ]
      
      # At this point we have to use the variable formula to get our unique model, as chosen by the user
      formulaFull <- paste("Revenue ~ ", formula)
      
      glmFit <- glm(as.formula(formulaFull), data = trainingData, family = "binomial")
      classTreeFit <- tree(as.formula(formulaFull), data = trainingData)
      randomForestFit <- train(as.formula(formulaFull), data = trainingData,
                                   method = "ranger",
                                   trControl = trainControl(method = "cv",
                                                            number = 5),
                                   tuneGrid = expand.grid(.mtry = seq(1, min(8, length(input$modelVariables))),
                                                          .splitrule = "gini",
                                                          .min.node.size = c(10, 20)
                                   ))
      
      return(list("Linear Model",
                  glmFit,
                  "Classification Tree Model",
                  classTreeFit,
                  "Random Forest Model",
                  randomForestFit
                  ))
        
    })
    
    output$linearModel <- renderPrint({
      glmModel <- models()[c(1,2)]
      glmModel[[2]] <- summary(glmModel[[2]])
      glmModel
    })
    
    output$classTreeModel <- renderPrint({
      treeModel <- models()[c(3,4)]
      treeModel[[2]] <- summary(treeModel[[2]])
      treeModel
    })
    
    output$classTreeGraph <- renderPlot({
      treeModel <- models()[[4]]
      plot(treeModel)
      text(treeModel)
    })
    
    output$randomForestModel <- renderPrint({
      forestModel <- models()[c(5,6)]
      forestModel
    })
    
    output$randomForestGraph <- renderPlot({
      forestModel <- models()[[6]]
      plot(forestModel)
    })
    
    predictionModel <- eventReactive(input$startPredict, {
      allData <- getData()
      set.seed(144)
      shoppingIndex <- createDataPartition(allData$Revenue, p = 0.1, list = FALSE)
      trainingData <- allData[shoppingIndex, ]
      reducedTreeFit <- tree(Revenue ~ ExitRates + PageValues + TrafficType, data = trainingData)
      
      shopperPredict <- allData[1,]
      shopperPredict[1,8] <- input$predictExitRates
      shopperPredict[1,9] <- input$predictPageValues
      shopperPredict[1,15] <- as.factor(input$predictTrafficType)
      return(list(reducedTreeFit, shopperPredict))
    })
    
    output$prediction <- renderText({
      reducedTreeFit <- predictionModel()[[1]]
      shopperPredict <- predictionModel()[[2]]
      result <- predict(reducedTreeFit, shopperPredict, type = "class")
      if (as.logical(result) == FALSE) {
        return("A shopper with these statistics is LESS likely than not to make a transaction.")
      } else {
        return("A shopper with these statistics is MORE likely than not to make a transaction.")
      }
    })

})

