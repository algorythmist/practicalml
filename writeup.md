

Workout Classification
========================================================

## Overview
The objective of this project is to differentiate between various wrong ways (and one correct way) of performing a workout involving dumpbells. The data set consists of various measurments obtained by wearable hardware.

## Cleaning and preprocessing data

There are originally 160 predictors and no codebook. A cursory glance at the data after reveals that:

* Some of the predictors do not seem to be related to measurments.
* When reading the file as CSV some values are missinterpreted as factors instead of numbers.
* A lot of the values contain NA.

Before doing any kind of prediction, we start by aleviating some of the problems.
We load the training set in this manner in order to fill in NA values instead of blank strings:


```r
training = read.csv("pml-training.csv",stringsAsFactors=F,na.strings=c("NA",""))
```

The next step is to remove any "predictors" that are not related to measurments. 
In my estimation, these are the first 7 fields:

* "X" - This is just a sample index             
* "user_name" - This identify the person performing the exercise.          
* "raw_timestamp_part_1" - timestamp
* "raw_timestamp_part_2" - timestamp
* "cvtd_timestamp" - timestamp      
* "new_window"  - no idea            
* "num_window" - no idea

The following function rids us of these fields

```r
removeUseless <- function(dataSet) {
  #variables that do not correspond to measurments
  useless = c(1,2,3,4,5,6,7)
  dataSet = dataSet[,-useless]
  return(dataSet)
}
```

Whereas it is possible for some learning algorithms to function with NAs in data, most of them require clean data.
We have no insight into why some data is missing in the set or how to impute it, so it is best to try solving the problem for the subset of the data without NAs. To accomplish this we first convert everything to numeric:


```r
#Coerse all columns to numeric. Note that anything that cannot be coersed will be turned into NA
makeNumeric <- function(dataSet) {
    return (data.frame(apply(dataSet, 2, as.numeric)))
}
```

And then eliminate any columns that contain NA values:


```r
removeNA <- function(dataSet) {
  cols = sapply(dataSet, function(x) { any(is.na(x)) })
  return (dataSet[,!cols])
}
```

Note that the last two steps drop the "classe" column, so we need to add it back to the dataset before training.
The result is a dataset of 53 variables with no NA values. Although it is possible to reduce the dimensionality further in several ways, this seems like a reasonable enough number of predictors.

## Training

Random Forests are widely successful as "black box" classifiers, so we can try one and see where it leads us. 
It quickly becomes apparent that using the **train** method of the caret package requires significant patience. On the other hand, using the **randomForest** package directly produces results quite quickly, even with all the predictors, all the rows, and many trees.

The following method creates test and training sets, trains a random forest, and the computes the accuracy on the test set.


```r
trainAndTest <- function(cleanData, trees) {
  inTrain = createDataPartition(cleanData$classe, p = .7)[[1]]
  trainSet = cleanData[ inTrain,]
  testSet = cleanData[-inTrain,]
  model = randomForest(classe~.,data=trainSet,ntree=trees)
  prediction <- predict(model, testSet)
  return (postResample(prediction, testSet$classe))
}
```

The function trains very fast, so it allows us the luxury to experiment with the number of trees.
The following plot illustrates that once you go over 100 trees, accuracy stays pretty much constant.

![image for trees](rf.png)

## Out of Sample Error Estimate


An advantage of random forests is that there is no need for cross-validation or a separate test set to get an unbiased estimate of the test set error. It is estimated internally as part of training. More details on how this happens can be found at http://www.stat.berkeley.edu/~breiman/RandomForests/cc_home.htm

Nevertheless, it is easy to experimentally verify this claim. Printing a model that we trained using the random training set we obtain:


```r
inTrain = createDataPartition(cleanData$classe, p = .7)[[1]]
trainSet = cleanData[ inTrain,]
model = randomForest(classe~.,data=trainSet,ntree=200)
```
        OOB estimate of  error rate: 0.56%

Note that the OOB (Out Of Box) estimate is 0.56% which means 0.0056.

Let us compute the error rate on the test set:


```r
testSet = cleanData[-inTrain,]
prediction <- predict(model, testSet)
error = 1 - postResample(prediction, testSet$classe)[[1]]
```

Yields an error of 0.004587935, which is in the same order of magnitude.

## Conclusion

The main conclusion of this brief exercise is that Random Forests can be quite powerful. With limitted understanding of the data and very basic preprocessing, a random forest achieved a very high prediction accuracy.

## R code

All the R code for this project is checked into the Git repository, as well as the data used.

* preprocess.R - The methods used to preprocess the data
* trainint.R - The methods used to train and test
* Project.R - Some of the steps performed to produce this writeup



