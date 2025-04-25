# Install and load necessary packages
if (!require("corrplot")) install.packages("corrplot")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("GGally")) install.packages("GGally")
if (!require("caret")) install.packages("caret")
if (!require("ROCR")) install.packages("ROCR")

library(corrplot)
library(ggplot2)
library(dplyr)
library(GGally)
library(caret)
library(ROCR)

# Load the dataset
df <- read.csv("C:/Users/SOHAM/Music/heart_updated_random_v2.csv") # Replace with actual path

# Check the structure of the data
str(df)

# Drop the empty column if present
df <- df[, colSums(is.na(df)) < nrow(df)]

# Convert categorical variables to factors
df$Sex <- as.factor(df$Sex)
df$ChestPainType <- as.factor(df$ChestPainType)
df$FastingBS <- as.factor(df$FastingBS)
df$RestingECG <- as.factor(df$RestingECG)
df$ExerciseAngina <- as.factor(df$ExerciseAngina)
df$ST_Slope <- as.factor(df$ST_Slope)

# Remove rows with missing values
df <- na.omit(df)

# Convert categorical variables to numeric for correlation
df$Sex_numeric <- ifelse(df$Sex == "M", 1, 0)
df$ExerciseAngina_numeric <- ifelse(df$ExerciseAngina == "Y", 1, 0)
df$RestingECG_numeric <- as.numeric(df$RestingECG) - 1  # Convert to 0-based
df$ChestPainType_numeric <- as.numeric(df$ChestPainType) - 1  # Convert to 0-based

# Calculate the correlation matrix for numeric variables, including new numeric columns
cor_matrix <- cor(df[, sapply(df, is.numeric)])

# Visualize the correlation matrix
corrplot(cor_matrix, method = "color", type = "upper", order = "hclust", 
         col = colorRampPalette(c("blue", "white", "red"))(200), 
         addCoef.col = "black", number.cex = 0.7)

# Correlation of individual variables with HeartDisease
target_correlation <- cor(df$HeartDisease, df[, sapply(df, is.numeric)], use = "complete.obs")
print(target_correlation)

# Scatter plot example: Age vs MaxHR, colored by HeartDisease status
ggplot(df, aes(x = Age, y = MaxHR, color = as.factor(HeartDisease))) + 
  geom_point() +
  labs(title = "Age vs Maximum Heart Rate, Colored by Heart Disease Status", 
       x = "Age", y = "Maximum Heart Rate", color = "Heart Disease")

# Pair plot to show relationships between key features
ggpairs(df, columns = c("Age", "MaxHR", "Cholesterol", "RestingBP", "HeartDisease"), 
        aes(color = as.factor(HeartDisease)))

# Build a logistic regression model including the new numeric columns
model <- glm(HeartDisease ~ MaxHR + Oldpeak + Sex_numeric + ExerciseAngina_numeric  + ChestPainType_numeric, 
             data = df, family = binomial)

# Summarize the model to check coefficients
summary(model)

# Predict probabilities for each instance in the dataset
df$Predicted_Probabilities <- predict(model, type = "response")

# Classify predictions: if probability > 0.5, predict Heart Disease = 1 (has heart disease)
df$Predicted_HeartDisease <- ifelse(df$Predicted_Probabilities > 0.5, 1, 0)

# Create a confusion matrix to evaluate the model's performance
confusion_matrix <- table(df$Predicted_HeartDisease, df$HeartDisease)
print("Confusion Matrix:")
print(confusion_matrix)

# Calculate and print accuracy
accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
print(paste("Accuracy:", round(accuracy * 100, 2), "%"))

# ROC curve for evaluating the model
pred <- prediction(df$Predicted_Probabilities, df$HeartDisease)
perf <- performance(pred, "tpr", "fpr")
plot(perf, col = "blue", main = "ROC Curve")
abline(a = 0, b = 1, lty = 2, col = "gray")
auc <- performance(pred, "auc")@y.values[[1]]
print(paste("AUC:", round(auc, 2)))

# Update the prediction function to include the new variables
predict_heart_disease <- function(model) {
  model <- glm(HeartDisease ~ MaxHR + Oldpeak + Sex_numeric + ExerciseAngina_numeric  + ChestPainType_numeric, 
               data = df, family = binomial)
  age <- as.numeric(readline(prompt = "Enter your age: "))
  sex <- as.character(readline(prompt = "Enter your sex (M/F): "))
  cholesterol <- as.numeric(readline(prompt = "Enter your cholesterol level: "))
  resting_bp <- as.numeric(readline(prompt = "Enter your resting blood pressure: "))
  max_hr <- as.numeric(readline(prompt = "Enter your maximum heart rate: "))
  oldpeak <- as.numeric(readline(prompt = "Enter your oldpeak value (depression): "))
  exercise_angina <- as.character(readline(prompt = "Do you have exercise angina? (Y/N): "))
  resting_ecg <- as.integer(readline(prompt = "Enter Resting ECG (0=Normal, 1=ST, 2=LVH): "))
  chest_pain <- as.integer(readline(prompt = "Enter Chest Pain Type (0=ATA, 1=NAP, 2=ASY, 3=TA): "))
  
  # Convert input to numeric format for prediction
  sex_numeric <- ifelse(toupper(sex) == "M", 1, 0)
  exercise_angina_numeric <- ifelse(toupper(exercise_angina) == "Y", 1, 0)
  
  # Create a data frame for prediction
  user_data <- data.frame(Age = age, MaxHR = max_hr, Cholesterol = cholesterol, 
                          RestingBP = resting_bp, Oldpeak = oldpeak, 
                          Sex_numeric = sex_numeric, ExerciseAngina_numeric = exercise_angina_numeric,
                          RestingECG_numeric = resting_ecg, ChestPainType_numeric = chest_pain)
  
  # Predict the probability
  predicted_prob <- predict(model, newdata = user_data, type = "response")
  
  # Calculate the percentage chance
  percentage_chance <- round(predicted_prob * 100, 2)
  
  # Display the result
  print(paste("The predicted probability that you have heart disease is:", 
              percentage_chance, "%"))
}
# Run the prediction function
predict_heart_disease()
