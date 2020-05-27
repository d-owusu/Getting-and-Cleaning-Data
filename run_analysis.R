#packages and load the data 

packages <- c('data.table','reshape2')
sapply(packages,require, character.only = T ,quietly = T)
path <-getwd()
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(url, file.path(path, 'analysisfiles.zip'))
unzip(zipfile = 'analysisfiles.zip')

##Load Labels and the features
activitylabels<- fread(file.path(path,'UCI HAR Dataset/activity_labels.txt'),
                       col.names = c('classlable','activityname'))

features<- fread(file.path(path,'UCI HAR Dataset/features.txt'),
                 col.names = c('index','featurenames'))

features_mean_std<- grep('mean|std\\(\\)',features[,2])

measurements<-features[features_mean_std,featurenames]

measurements<- gsub('[()]','',measurements)


## Load training data
train <- fread(file.path(path,'UCI HAR Dataset/train/X_train.txt'))[,features_mean_std, with = F]

setnames(train,colnames(train),measurements)

trainActivities <- fread(file.path(path, 'UCI HAR Dataset/train/Y_train.txt'), col.names = c('activity'))

trainSubjects <- fread(file.path(path, 'UCI HAR Dataset/train/subject_train.txt'), col.names = c('subject'))

train <- cbind(trainSubjects, trainActivities,train)


## Load test data

test <- fread(file.path(path,'UCI HAR Dataset/test/X_test.txt'))[,features_mean_std, with= F]

setnames(test, colnames(test),measurements)

testActivities<- fread(file.path(path,'UCI HAR Dataset/test/Y_test.txt'),col.names = c('activity'))

testSubjects<- fread(file.path(path,'UCI HAR Dataset/test/subject_test.txt'),col.names = c('subject'))

test <-cbind(testSubjects,testActivities, test)


##merge the datasets

merged <- rbind(train,test)

## class labels to ativity labels

merged[['activity']]<-factor(merged[,activity],
                           levels = activitylabels[['classlable']],
                           labels = activitylabels[['activityname']])


merged[['subject']] <- as.factor(merged[,subject])
merged<- melt(merged,id= c('subject','activity'))
merged<- dcast(merged,subject + activity ~ variable , fun.aggregate = mean)

fwrite(merged, 'tidyData.txt',quote = F)

