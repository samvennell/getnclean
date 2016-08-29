##
##   Project Name:  Getting and Cleaning Data Course Project
##                   
##   Objective:     Produce a tidy dataset containing the average of each measure of mean and standard deviation for each
##                  subject and activity type from the testing and training data in the UCI HAR Dataset.
##
##   Approach:      - Load the testing and training data, as well as activities and features data.
##                  - Groom and combine the testing and training data, along with the activity and feature information
##                  - Use regular expressions to extract only the measurements of the mean and standard deviation for each measurement.
##                  - Store the resultant data in a wide-format data frame "UCIHAR_meansd_wide"
##                  - "Gather" the data into a "narrow" format and store in data frame "UCIHAR_meansd"
##                  - Summarise the data in a new data frame "UCIHAR_meansd_avg" containing the average of each variable for each activity 
##                      and each subject.
##                  - Write this final table to "UCIHAR_meansd_avg.txt" in the "dataoutput" directory  
##
##
##   Author:        Sam Vennell
##
##   Date:          27 Aug 2016
##



  ##  Set up

  
  library(dplyr)
  library(tidyr)

  ## Import Data
      
      #Load the Test Data
          testdata.x <- read.table("UCI HAR Dataset\\test\\X_test.txt")
          testdata.y <- read.table("UCI HAR Dataset\\test\\y_test.txt")
          testdata.subject_test <- read.table("UCI HAR Dataset\\test\\subject_test.txt")
      
      #Load the Training Data
          traindata.x <- read.table("UCI HAR Dataset\\train\\X_train.txt")
          traindata.y <- read.table("UCI HAR Dataset\\train\\y_train.txt")
          traindata.subject_test <- read.table("UCI HAR Dataset\\train\\subject_train.txt")
      
      # Load activity lables / features    
          activity_labels <- read.table("UCI HAR Dataset\\activity_labels.txt")
          features <- read.table("UCI HAR Dataset\\features.txt")
      
      
  ## Put it all together
      
      #Test data
          testdata<-data.frame(subject_ID=testdata.subject_test$V1,
                               activity_ID=testdata.y$V1,  
                               activitydesc = activity_labels[testdata.y$V1,2], 
                               datatype = "Test", 
                               testdata.x)
          names(testdata)[-(1:4)] <- as.character(features$V2)
          
      #Train data
          traindata<-data.frame(subject_ID=traindata.subject_test$V1,
                                activity_ID = traindata.y$V1, 
                                activitydesc = activity_labels[traindata.y$V1,2],
                                datatype = "Train",
                                traindata.x)
          names(traindata)[-(1:4)] <- as.character(features$V2)
          
      #Combine Training and Test Data
          combdata <- rbind(testdata,traindata) 

  ## Extract only the measurements of the mean and standard deviation for each measurement
          UCIHAR_meansd_wide <- combdata[, c(1:4, 
                                        grep("(^.*-(mean|std)\\(\\))|(^angle\\(.*Mean.*\\))",
                                             names(combdata)) ) ]
          
          # A tidyer "narrow" format version
          UCIHAR_meansd <- gather(UCIHAR_meansd_wide,variable,
                                       value,-(1:4))
          
          
  ## Create an independent, tidy data set with the average of each variable 
  ##        for each activity and each subject.
          
          ##NB I have opted to combine the training and test data for this purpose
          
          UCIHAR_meansd_avg <- UCIHAR_meansd %>% 
                                  group_by(subject_ID, activity_ID, activitydesc, variable) %>%
                                  summarise(average=mean(value))
  
  
  ##  Write this final table to "UCIHAR_meansd_avg.txt" in the "dataoutput" directory      
  
  write.table(UCIHAR_meansd_avg, file= paste0(getwd(),"/dataoutput/UCIHAR_meansd_avg.txt"))
