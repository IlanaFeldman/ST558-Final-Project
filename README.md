# ST558-Final-Project

The goal of this project is to create a Shiny app that can explore and model the data I have chosen. This README.md file contains the following:  

  1. A brief description of the app and its purpose  
  2. A list of packages needed to run the app (Incomplete)  
  3. A line of code that will install all the packages needed (Incomplete)  
  4. The shiny::runGitHub() code that can be copied and pasted into RStudio to run the app.  

## Description

This app is intended to be an exploratory app, which allows the user to easily and quickly work with the given online shopper data, which can be found [here](https://archive.ics.uci.edu/ml/datasets/Online+Shoppers+Purchasing+Intention+Dataset). This includes summarization, modeling, predicting, and, of course, viewing the data.

## Packages and Startup

This includes a fairly basic set of packages: `tidyverse`, `shiny`, and `tree` are all required. Additionally, I have included `caret` and `ranger` to make some of the computations easier. These packages can be installed with the following line of code:

`install.packages(c("shiny", "tidyverse", "tree", "caret", "ranger"))`

I have kept my environment empty for the entirety of my time working on this project, and tested everything in a separate session. To run the app. you should use the code `shiny::runGitHub(repo = "ST558-Final-Project", username = "IlanaFeldman").