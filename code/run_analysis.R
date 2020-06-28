library(dplyr)

# download and extract rawdata folder if it does not already exist
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfilepath <- "rawdata//raw_dataset.zip"
if (!file.exists(destfilepath)){
    download.file(url=url, destfile=destfilepath)
}
if (!file.exists("rawdata//UCI HAR Dataset//train//X_train.txt")){
    unzip(destfilepath, exdir="rawdata//.")
}

# read train data and its corresponding labels
dat_train <- read.table(
    file = "rawdata//UCI HAR Dataset//train//X_train.txt"
)
# activity lables, factor variable
con <- file("rawdata//UCI HAR Dataset//train//y_train.txt")
train_labels <- readLines(con)
close(con)
dat_train <- cbind(train_labels, dat_train)
# subject group identifier variable
con <- file("rawdata//UCI HAR Dataset//train//subject_train.txt")
train_subject <- readLines(con)
close(con)
dat_train <- cbind(train_subject, dat_train)
colnames(dat_train)[2] <- "activitytype"

# read test data and its corresponding variables names and labels
dat_test <- read.table(
    file = "rawdata//UCI HAR Dataset//test//X_test.txt"
)
con <- file("rawdata//UCI HAR Dataset//test//y_test.txt")
test_labels <- readLines(con)
close(con)
dat_test <- cbind(test_labels, dat_test)
colnames(dat_test)[1] <- "activitytype"

# characters to attach to activity factor variable after merging
con <- file("rawdata//UCI HAR Dataset//activity_labels.txt")
activity_labels <- readLines(con)
close(con)
# mebbe remove non_factored rows in data_train? the lower rows have no activity type
rm(list=c("test_labels", "train_labels", "train_subject", "url"))
dat_train <- dat_train[!(which(is.na(dat_train$activitytype))), ]
dat_merged <- merge(x=dat_train, y=dat_test, by.x="activitytype", by.y="activitytype")
levels(dat_merged$activitytype) <- activity_labels