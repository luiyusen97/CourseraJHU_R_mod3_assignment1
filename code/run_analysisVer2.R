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
experimenttype_levels <- c("train", "test")
levels(dat_merge$experimenttype) <- experimenttype_levels
# extract the mean and standard deviation for each column variable
column_names <- colnames(dat_merge)
required_columns <- grep(x=column_names, pattern="mean|std|subject|activity|experimenttype")
dat_merge <- dat_merge[ , required_columns]
# split merged dataset (or before merge also can) by subject label/code
dat_merged_splitbysubject <- split(x=dat_merge, f=dat_merge$subject)
# use dplyr group by activity label
dat_avg_values <- data.frame()
dat_merge_ordered <- data.frame()
for (ele in dat_merged_splitbysubject){
    # order and group within each subject's data by activity type
    ele <- arrange(ele, ele$activity)
    ele <- group_by(ele, ele$activity)
    # preserve the first 3 identifier columns, calculate means for the rest
    ele_avg <- summarise(ele, across(.cols=1:3), across(.cols=4:82, .fns=mean))
    # preserving first 3 columns creates duplicate rows (since there are now less mean values than 
    # rows), so remove them
    ele_avg <- distinct(ele_avg)
    # compile all average values into a second, tidy dataframe
    dat_avg_values <- rbind(dat_avg_values, ele_avg)
    # compile all original values into an ordered, tidy dataframe
    dat_merge_ordered <- rbind(dat_merge_ordered, ele)
}
# remove redundant variables. These variables have already been used or have been added to the data
# frames
rm(list=c("dat_merge", "dat_test", "dat_train", "ele", "ele_avg",
     "colnames_vector", "column_names", "con", "destfilepath", "i", "required_columns",
     "test_activity_labels", "test_factor_vector", "test_subject_labels", 
     "train_activity_labels", "train_factor_vector", "train_subject_labels", "url"))

# write the outputted dataframes to tab separated files
# the delimiter is tab, and when reading these files, header should be true, since colnames are 
# included
con <- file("output//dat_avg_values.txt", "wt")
write.table(x = dat_avg_values,
            file = con,
            sep = "\t", col.names = TRUE, row.names=F
)
close(con)
con <- file("output//dat_merge_ordered.txt", "wt")
write.table(x = dat_merge_ordered,
            file = con,
            sep = "\t", col.names = TRUE, row.names=F
)
close(con)
# for the split dataframe, this is a list of dataframes, with each dataframe containing the data for
# all 6 activiies for a single subject. Thus, it is read into a separate folder with indexed names
# for each dataframe
# create the file names
filenames <- vector(mode="character")
for (i in 1:30){
    name <- paste0("subject", as.character(i))
    filenames <- c(filenames, name)
}
# iterate through all the file names and the dataframes and write each one into a tab separated txt file
for (i in 1:30){
    con <- file(paste0("output//individualsubjectdata//", filenames[i], ".txt"), open="wt")
    write.table(x = dat_merged_splitbysubject[i],
                file = con,
                sep = "\t", col.names = TRUE, row.names=F
                )
    close(con)
}