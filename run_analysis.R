library(reshape2)
filePath <-  "./data/Project_File.zip"

## Download and unzip the dataset:
if (!file.exists(filePath)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filePath, mode="wb")
}  
if (!file.exists("./data/UCI HAR Dataset")) { 
    unzip(filePath) 
}

# Load the features 
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Search for the features that have mean and std on measurements.
featuresWith_mean_std <- grep(".*[m]ean.*|.*[s]td.*", features[,2])
featuresWith_mean_std_names <- features[featuresWith_mean_std,2]

# Load the datasets - train 
subjects_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
activities_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
measurement_train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWith_mean_std]

trainingSet <- cbind(subjects_train, activities_train, measurement_train)

# Load the datasets - test
subjects_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
activities_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
measurement_test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWith_mean_std]

testSet <- cbind(subjects_test, activities_test, measurement_test)

# Merges the trainingSet and the testSet sets to create one data set.
# Appropriately labels the data set with descriptive variable names.
DataSet <- rbind(trainingSet,testSet)
names(DataSet) <- c("subject", "activity", featuresWith_mean_std_names)

# Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
DataSet$activity <- factor(DataSet$activity , levels = c(1:6), labels = activityLabels[,2])
DataSet$subject <- factor(DataSet$subject)

# From the data set in step 4, creates a second,
# independent tidy data set with the average of
# each variable for each activity and each subject.

DataSetMelt <- melt(DataSet, id = c("subject", "activity"))
tidy <- dcast(DataSetMelt, subject + activity ~ variable, mean)

# Write to "txt" file with the final data 
write.table(tidy, "tidy.txt", row.names = FALSE)

# Write to "csv" file with the final data 
write.csv(tidy, file = "tidy.csv", row.names = FALSE)
