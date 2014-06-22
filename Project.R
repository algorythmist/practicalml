#What you should submit

#The goal of your project is to predict the manner in which they did the exercise. 
#This is the "classe" variable in the training set. 
#You may use any of the other variables to predict with. 
#You should create a report describing how you built your model, 
#how you used cross validation, what you think the expected out of sample error is, 
#and why you made the choices you did. 
#You will also use your prediction model to predict 20 different test cases. 

#1. Your submission should consist of a link to a Github repo with your R markdown and compiled HTML file describing your analysis. 
#Please constrain the text of the writeup to < 2000 words and the number of figures to be less than 5. 
#It will make it easier for the graders if you submit a repo with a gh-pages branch so the HTML page can be viewed online 
#(and you always want to make it easy on graders :-).
#2. You should also apply your machine learning algorithm to the 20 test cases available in the test data above. 
#Please submit your predictions in appropriate format to the programming assignment for automated grading. 
#See the programming assignment for additional details. 

#Reproducibility 

#Due to security concerns with the exchange of R code, 
#your code will not be run during the evaluation by your classmates. 
#Please be sure that if they download the repo, they will be able to view the compiled HTML version of your analysis. 

setwd("Documents/workspaces/courses/practical_ml/project/practicalml")

training = read.csv("pml-training.csv",stringsAsFactors=F,na.strings=c("NA",""))
source("preprocess.R")
source("training.R")
cleanData = getCleanData(training)

# Plot accuracy as a function of trees used
trees = c(1,10,25,50,100,150,200,250,300,400,500)
a = lapply(trees,getAccuracy)
plot(trees,a,main="Accuracy vs number of trees in the Forest",ylab="accuracy")

prediction <- predict(model, testSet)
error = 1 - postResample(prediction, testSet$classe)[[1]]

#Train a forest
inTrain = createDataPartition(cleanData$classe, p = .7)[[1]]
trainSet = cleanData[ inTrain,]
model = randomForest(classe~.,data=trainSet,ntree=200)

#Compute error on the test set
testSet = cleanData[-inTrain,]
prediction <- predict(model, testSet)
error = 1 - postResample(prediction, testSet$classe)[[1]]

