# Load required libraries
library(dplyr)
 # Define the file URL and name
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filename <- "Coursera_Week4_FinalAssignment.zip"

# Download and unzip the data if it doesn't exist
if (!file.exists(filename)) { 
   download.file(fileURL, filename, method = "curl")
}

if (!file.exists("UCI HAR Dataset")) {
   unzip(filename)
}

# Load the text files into individual dataframe
activites <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("activity_id", "activity"))
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("feature_id", "feature"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "label")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "label")

# Rename the column names
colnames(x_test) <- features$feature
colnames(x_train) <- features$feature

# Select colums that contains mean or std
x_test <- x_test %>% select(contains("mean") | contains("std"))
x_train <- x_train %>% select(contains("mean") | contains("std"))

# Merge test and train dataset
test <- cbind(subject_test, y_test, x_test)
train <- cbind(subject_train, y_train, x_train)
all_data <- rbind(test,train)
head(all_data,10)

# Replace activity number with activity name
all_data <- all_data %>%
        mutate(label = activites[all_data$label, 2])

# Rename column
names(all_data)[2] <- "activity"
names(all_data) <- gsub("-mean", "_mean", names(all_data))
names(all_data) <- gsub("-std", "_std", names(all_data))
names(all_data) <- gsub( "Acc", "_accelerometer", names(all_data))
names(all_data) <- gsub("Gyro", "_gyroscope", names(all_data))
names(all_data) <- gsub("BodyBody", "Body", names(all_data))

# Calculate the average
avg_of_columns <- all_data %>%
        group_by(subject, activity) %>%
        summarise_all(mean)

avg_of_columns

# Exportiing the datset and average of columns to text file
write.table(all_data, file = "tidydata.txt", row.names = FALSE)
write.table(avg_of_columns, "final.txt", row.names = FALSE)
