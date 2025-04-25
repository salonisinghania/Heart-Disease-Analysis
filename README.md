
# Heart Disease Prediction 

This project analyzes a heart disease dataset and builds a logistic regression model to predict the probability of a patient having heart disease.

## 📁 Dataset

- File used: `heart_updated_random_v2.csv`
- You must place this dataset in your working directory.

## 📦 Required Packages

```r
if (!require("corrplot")) install.packages("corrplot")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("GGally")) install.packages("GGally")
if (!require("caret")) install.packages("caret")
if (!require("ROCR")) install.packages("ROCR")
```

## 📊 Data Preprocessing

- Loaded dataset with `read.csv()`
- Removed empty columns
- Converted categorical columns to factors
- Replaced categorical values with numeric equivalents for modeling
- Removed rows with missing data

## 🔍 Exploratory Data Analysis

- Displayed structure of the dataset
- Generated correlation matrix with `corrplot`
- Created scatter plot (e.g., Age vs MaxHR)
- Visualized key variable relationships using `ggpairs()`

## 🧠 Logistic Regression Model

- Logistic regression model built using predictors:
  - MaxHR
  - Oldpeak
  - Sex (numeric)
  - Exercise Angina (numeric)
  - Chest Pain Type (numeric)

```r
model <- glm(HeartDisease ~ MaxHR + Oldpeak + Sex_numeric + ExerciseAngina_numeric + ChestPainType_numeric,
             data = df, family = binomial)
```

## 📈 Model Evaluation

- Predictions made using `predict()`
- Classified with 0.5 threshold
- Accuracy calculated from confusion matrix
- ROC curve plotted using `ROCR`
- AUC value printed

## 🤖 User Input Prediction

Interactive function that allows user to enter medical parameters and receive a prediction on heart disease probability:

```r
predict_heart_disease()
```

Prompts user for:
- Age
- Sex (M/F)
- Cholesterol
- Resting BP
- Max HR
- Oldpeak
- Exercise Angina (Y/N)
- Resting ECG (0, 1, 2)
- Chest Pain Type (0, 1, 2, 3)

## 📌 Output Example

```
The predicted probability that you have heart disease is: 67.45 %
```

## 📂 Folder Structure

```
project/
├── heart_updated_random_v2.csv
├── heart_disease_prediction.R
├── README.md
```

## 📬 Note
Make sure the path to your dataset is correctly specified in `read.csv()`.

---


