# Restrict the dataset to only those predictors that have std above a threshold
removeLowVar <- function(dataSet, classIndex) {
  M <- abs(cor(dataSet[,-classIndex]))
  diag(M) <- 0
  return (dataSet[,which(M > 0.8,arr.ind=T)])
}

#Run all preprocessing steps on the dataset
preprocess <-function(dataSet) {
  return (removeNA(makeNumeric(removeUseless(dataSet))))
}

removeNA <- function(dataSet) {
  cols = sapply(dataSet, function(x) { any(is.na(x)) })
  return (dataSet[,!cols])
}

#Remove predictors that do not correspond to measurments
removeUseless <- function(dataSet) {
  #variables that do not correspond to measurments
  useless = c(1,2,3,4,5,6,7)
  dataSet = dataSet[,-useless]
  return(dataSet)
}

#Coerse all columns to numeric. Note that anything that cannot be coersed will be turned into NA
makeNumeric <- function(dataSet) {
    return (data.frame(apply(dataSet, 2, as.numeric)))
}


