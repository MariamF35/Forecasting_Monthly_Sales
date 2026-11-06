# Monthly Sales Forecasting Using Time Series Analysis

## 📌 Project Overview

This project focuses on forecasting monthly sales quantity using historical retail sales data and Time Series Analysis.

The objective is to analyse historical sales patterns, identify trends and seasonal variations, and predict future monthly sales quantities using statistical forecasting techniques implemented in **R Programming Language**.

Three forecasting algorithms are implemented and compared to identify the most suitable model for predicting future sales.

## 🎯 Objectives

- Analyse historical sales data.
- Convert transaction-level sales records into monthly sales quantities.
- Identify sales trends and seasonal patterns.
- Implement ARIMA, Holt-Winters Exponential Smoothing and Seasonal Naive Forecasting.
- Evaluate and compare the performance of the forecasting algorithms.
- Predict future monthly sales quantities.
- Visualize actual sales and forecasted results using graphs.

## 📂 Dataset

**Source:** [Sales Dataset – Kaggle](https://www.kaggle.com/datasets/sahilislam007/sales-dataset)

The project uses a publicly available retail sales dataset from Kaggle.

The dataset will be preprocessed and aggregated into monthly sales quantities before applying forecasting algorithms.

## 🧠 Algorithms Used

### 1. ARIMA (AutoRegressive Integrated Moving Average)

ARIMA is a statistical forecasting technique that uses historical observations and their relationships to predict future values. It is useful for modelling time-series patterns.

### 2. Holt-Winters Exponential Smoothing (ETS)

Holt-Winters is an exponential smoothing technique that considers the level, trend and seasonal components of time-series data to generate forecasts.

### 3. Seasonal Naive Forecasting

Seasonal Naive is a baseline forecasting method that assumes the value for a particular month will be similar to the value recorded in the same month of the previous year.

## 🛠️ Technologies Used

- **Programming Language:** R
- **IDE:** RStudio
- **Dataset Source:** Kaggle
- **Data Processing:** dplyr, lubridate
- **Data Visualization:** ggplot2
- **Forecasting:** forecast
- **Model Evaluation:** MAE, RMSE and MAPE

## ⚙️ Project Methodology

1. Dataset Collection – Download the retail sales dataset from Kaggle.
2. Data Preprocessing – Handle missing values, convert date columns and prepare the data.
3. Monthly Aggregation – Calculate the total quantity sold for each month.
4. Exploratory Data Analysis – Visualize sales trends and identify seasonal patterns.
5. Model Implementation – Apply ARIMA, Holt-Winters and Seasonal Naive forecasting.
6. Model Evaluation – Compare the forecasting models using MAE, RMSE and MAPE.
7. Future Forecasting – Generate predictions for upcoming months.
8. Result Visualization – Display historical sales, model predictions and forecast comparisons.

## 📊 Expected Results

The project aims to generate:

- Monthly sales trend graphs.
- Actual versus predicted sales comparisons.
- Forecasting results from all three algorithms.
- Model performance comparison tables.
- Future monthly sales quantity predictions.
- Identification of the best-performing forecasting model.

## 📁 Project Structure

```text
Monthly-Sales-Forecasting/
│
├── data/
│   └── sales_dataset.csv
│
├── notebooks/
│   └── sales_analysis.ipynb
│
├── R/
│   └── sales_forecasting.R
│
├── results/
│   ├── graphs/
│   └── forecasts/
│
├── README.md
└── .gitignore
```

## 🚀 How to Run the Project

1. Clone this repository:

```bash
git clone <your-repository-url>
```

2. Open the project in RStudio.

3. Install the required packages:

```r
install.packages(c(
  "forecast",
  "dplyr",
  "lubridate",
  "ggplot2",
  "Metrics"
))
```

4. Place the Kaggle dataset inside the `data` folder.

5. Open `R/sales_forecasting.R`.

6. Run the script to preprocess the dataset, implement the forecasting algorithms and generate predictions.

## 📈 Model Evaluation

The algorithms will be evaluated using:

| Metric | Purpose |
|---|---|
| MAE | Measures the average absolute prediction error. |
| RMSE | Measures prediction error while penalizing larger errors. |
| MAPE | Measures average percentage prediction error. |

The model with the best performance on the testing data will be selected as the most suitable forecasting model.

## 🔮 Future Scope

- Extend forecasting to individual product categories.
- Develop an interactive sales forecasting dashboard using R Shiny.
- Explore additional forecasting techniques.
- Improve prediction accuracy using more historical sales data.

## 👥 Project Information

**Project Title:** Monthly Sales Forecasting Using Time Series Analysis

**Programming Language:** R

**Project Type:** Academic Case Study

**Domain:** Data Analytics and Time Series Forecasting

## 📚 References

- [Kaggle – Sales Dataset](https://www.kaggle.com/datasets/sahilislam007/sales-dataset)
- [Forecasting: Principles and Practice](https://otexts.com/fpp3/)
- [R Forecast Package Documentation](https://pkg.robjhyndman.com/forecast/)

---

*This project is developed for academic purposes to understand and implement time-series forecasting techniques using R.*
