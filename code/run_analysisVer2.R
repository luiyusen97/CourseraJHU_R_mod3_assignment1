library(tidyverse)
# train set is for 70% of participants, test is for the other 30%. They measure the same variables

# download and extract rawdata folder if it does not already exist
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfilepath <- "rawdata//raw_dataset.zip"
if (!file.exists(destfilepath)){
    download.file(url=url, destfile=destfilepath)
}
if (!file.exists("rawdata//UCI HAR Dataset//train//X_train.txt")){
    unzip(destfilepath, exdir="rawdata//.")
}

# first dataset
dat_train <- read.table(file = "rawdata//UCI HAR Dataset//train//X_train.txt",
                               header = FALSE
                        )
# second dataset
dat_test <- read.table(file = "rawdata//UCI HAR Dataset//test//X_test.txt",
                       header = FALSE
                       )

# train set activity lables, convert to factor variable
con <- file("rawdata//UCI HAR Dataset//train//y_train.txt")
train_activity_labels <- readLines(con)
close(con)
# train subject identifier variable
con <- file("rawdata//UCI HAR Dataset//train//subject_train.txt")
train_subject_labels <- readLines(con)
close(con)

# test set activity labels
con <- file("rawdata//UCI HAR Dataset//test//y_test.txt")
test_activity_labels <- readLines(con)
close(con)
# test set subject labels
con <- file("rawdata//UCI HAR Dataset//test//subject_test.txt")
test_subject_labels <- readLines(con)
close(con)

# colnames for both datasets, the types of measurements taken for each dimension, x, y, z.
con <- file("rawdata//UCI HAR Dataset//features.txt")
colnames_vector <- readLines(con)
close(con)
# characters to attach to activity factor variable after merging
con <- file("rawdata//UCI HAR Dataset//activity_labels.txt")
activity_labels_levels <- readLines(con)
close(con)
for (i in 1:length(activity_labels_levels)){
    activity_labels_levels[i] <- sub(x=activity_labels_levels[i], pattern=".* ", replacement="")
}
for (i in 1:length(colnames_vector)){
    colnames_vector[i] <- sub(x=colnames_vector[i], pattern=".* ", replacement="")
}

# attach colnames to each dataset. Rmb to avoid first 3 columns which are the abovementioned cbound columns
colnames(dat_train) <- colnames_vector
colnames(dat_test) <- colnames_vector
# cbind subject, activity labels, then a factor variable idenifying test or train to the left of each data set
train_factor_vector <- c(rep(1, nrow(dat_train)))
dat_train <- cbind(train_subject_labels, train_activity_labels, train_factor_vector, dat_train)
colnames(dat_train)[1:3] <- c("subject", "activity", "experimenttype")
test_factor_vector <- c(rep(2, nrow(dat_test)))
dat_test <- cbind(test_subject_labels, test_activity_labels, test_factor_vector, dat_test)
colnames(dat_test)[1:3] <- c("subject", "activity", "experimenttype")
# merge data by rbinding test below train data
dat_merge <- rbind(dat_train, dat_test)
# convert subject and acivity columns to numeric class
dat_merge$subject <- apply(dat_merge[ , "subject", drop=F], 2, as.numeric)
dat_merge$activity <- apply(dat_merge[ , "activity", drop=F], 2, as.numeric)
# attach levels activity character vector to activity labels column to convert to factor variable
levels(dat_merge$activity) <- activity_labels_levels
# attach dataset identifier characters to 3rd column to convert to factor variable
levels(dat_merge$experimenttype) <- c("train", "test")
# extract the mean and standard deviation for each column variable
column_names <- colnames(dat_merge)
required_columns <- grep(x=column_names, pattern="mean|std|subject|activity|experimenttype")
dat_merge <- dat_merge[ , required_columns]
# split merged dataset (or before merge also can) by subject label/code
# use dplyr group by activity label
# calc the mean for every activity, for each subject. This returns a table of means for each variable, grouped by 
# activity, for each subject.
# Iterated over split list of dataframes, this returns a list of tidy dataframes
# rbind every dataframe, and order according to subject codes
# this should retain colnames