require(caret)
source("preprocess.R")

getCleanData <- function(dataSet) {
  classe = dataSet$classe
  dataSet = preprocess(dataSet);
  dataSet = data.frame(dataSet,classe=classe)
}

getRandomSample <- function(dataSet, samples) {
  trainInds <- sample(nrow(dataSet), samples)
  return (dataSet[trainInds,])
}

trainAndTest <- function(cleanData, trees) {
  inTrain = createDataPartition(cleanData$classe, p = .7)[[1]]
  trainSet = cleanData[ inTrain,]
  testSet = cleanData[-inTrain,]
  model = randomForest(classe~.,data=trainSet,ntree=trees)
  prediction <- predict(model, testSet)
  return (postResample(prediction, testSet$classe))
}

getAccuracy <- function(t) {
  return (trainAndTest(cleanData,t)[[1]])
}

trees = c(1,10,25,50,100,150,200,250,300,400,500)
a = lapply(trees,getAccuracy)

prediction <- predict(model, testSet)
postResample(prediction, testSet$classe)

#Accuracy     Kappa 
#0.9636667 0.9539567 