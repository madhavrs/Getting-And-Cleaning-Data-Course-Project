
## Read the TRAINING files 
y_training <- read.table("train/y_train.txt", sep="")
x_training <- read.table("train/X_train.txt", sep="")
subject_training <- read.table("train/subject_train.txt", sep="")

## Read the TEST files 
y_test <- read.table("test/y_test.txt", sep="")
x_test <- read.table("test/X_test.txt", sep="")
subject_test <- read.table("test/subject_test.txt", sep="")

## Read the FEATURES and ACTIVITY LABELS files 
features <- read.table("features.txt", sep="", col.names=c("index","feature"))
activities <- read.table("activity_labels.txt", sep="", col.names=c("activity_code","activity"))

## MERGE the TRAINING and TEST datasets 
training_data <- cbind(y_training, subject_training, x_training)
test_data <- cbind(y_test, subject_test, x_test)

## FINAL MERGED dataset 
merged_data <- rbind(training_data, test_data)

## Remove temporary data frames from the memory
rm(y_training, subject_training, x_training, y_test, subject_test, x_test, training_data, test_data)

##Extract only the measurements on the mean and standard deviation for each measurement
##Selecting those columns that have "mean()" and "std()" and "subject" and "activity"
features <- features[grepl("mean()|std()",features$feature),]
merged_data <- merged_data[,c(1,2,features$index+2)]

##Use descriptive activity names to name the activities in the data set
feature_names <- as.character(features$feature)
names(merged_data) <- c("subject","activity_code",feature_names)
merged_data <- merge(merged_data, activities, by.x="activity_code", 
                   by.y="activity_code", all=TRUE)[, c("subject","activity", feature_names)]

##Appropriately labels the data set with descriptive, expanded and meaningful variable names
names(merged_data) <- gsub("Acc", replacement = "Accelerometer", x = names(merged_data))
names(merged_data) <- gsub("Gyro", replacement = "Gyroscope", x = names(merged_data))
names(merged_data) <- gsub("Mag", replacement = "Magnitude", x = names(merged_data))
names(merged_data) <- gsub("BodyBody", replacement = "Body", x = names(merged_data))
names(merged_data) <- gsub("^t", replacement = "time", x = names(merged_data))
names(merged_data) <- gsub("^f", replacement = "frequency", x = names(merged_data))
names(merged_data) <- gsub("mean\\(\\)", replacement = "mean", x = names(merged_data))
names(merged_data) <- gsub("std\\(\\)", replacement = "std", x = names(merged_data))

##Create an independent tidy data set with the average of each variable for each activity and each subject
merged_data <- melt(merged_data, id.vars = c("subject", "activity"))
tidy_dataset <- dcast(merged_data, subject + activity ~ variable, mean)

## Writing the final tidy dataset to a TXT file
write.table(tidy_dataset, "tidy_dataset.txt", row.names=FALSE)
