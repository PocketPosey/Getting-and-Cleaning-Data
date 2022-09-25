if (!require("data.table")) {
        install.packages("data.table")
}

if (!require("reshape2")) {
        install.packages("reshape2")
}

require("data.table")
require("reshape2")

## Using read.table to load the activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

## Using read.table to load the features
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

## Code for Pulling only the mean and the standard deviation
mean_std <- grepl("mean|std", features)

## Load test data to table
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

## using the code from earlier
X_test = X_test[,mean_std]

## prepping the activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

## Bind the test data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

## Loadingn train data to table
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

## Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,mean_std]

## prepping the activity labels
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

## Bind the train data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

## Merge test and train data
data = rbind(test_data, train_data)

id_labels = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data = melt(data, id = id_labels, measure.vars = data_labels)

## Add the averages of each variable in.
tidy_dataset   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_dataset, file = "./tidy_dataset.txt")