
# ============================================================
# MONTHLY SALES FORECASTING SYSTEM
# Programming Language: R
# Dataset: Sales Dataset.csv
# ============================================================

# 1. INSTALL AND LOAD PACKAGES

packages <- c("forecast", "ggplot2")

for (p in packages) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p)
  }
}

library(forecast)
library(ggplot2)


# 2. LOAD DATASET

cat("Select your Sales Dataset.csv file\n")

file_path <- file.choose()

data <- read.csv(file_path, stringsAsFactors = FALSE)

cat("\nDataset loaded successfully!\n")
cat("\nColumn names:\n")
print(names(data))

cat("\nFirst few records:\n")
print(head(data))


# 3. IDENTIFY DATE AND SALES COLUMNS

date_col <- grep(
  "order.date|date|month",
  names(data),
  ignore.case = TRUE,
  value = TRUE
)[1]

sales_col <- grep(
  "^sales$|sales|revenue|amount",
  names(data),
  ignore.case = TRUE,
  value = TRUE
)[1]

if (is.na(date_col)) {
  date_col <- select.list(
    names(data),
    title = "Select the DATE column",
    graphics = FALSE
  )
}

if (is.na(sales_col)) {
  sales_col <- select.list(
    names(data),
    title = "Select the SALES column",
    graphics = FALSE
  )
}

if (date_col == "" || sales_col == "") {
  stop("Date or Sales column was not selected.")
}

cat("\nDate column:", date_col)
cat("\nSales column:", sales_col, "\n")


# 4. DATA PREPROCESSING

date_values <- as.character(data[[date_col]])

# Handle common date formats

if (all(grepl("^\\d{5}$", date_values))) {
  dates <- as.Date(as.numeric(date_values),
                   origin = "1899-12-30")
} else {
  dates <- as.Date(
    date_values,
    tryFormats = c(
      "%m/%d/%Y",
      "%Y-%m-%d",
      "%d/%m/%Y",
      "%d-%m-%Y",
      "%m-%d-%Y",
      "%m/%d/%Y %H:%M:%S",
      "%Y-%m-%d %H:%M:%S"
    )
  )
}

# Convert sales values into numeric format

sales <- as.numeric(
  gsub("[^0-9.-]", "", as.character(data[[sales_col]]))
)

clean_data <- data.frame(
  Date = dates,
  Sales = sales
)

clean_data <- clean_data[
  complete.cases(clean_data),
]

clean_data <- clean_data[
  clean_data$Sales >= 0,
]

cat("\nCleaned data:\n")
print(head(clean_data))


# 5. AGGREGATE SALES MONTHLY

clean_data$Month <- as.Date(
  format(clean_data$Date, "%Y-%m-01")
)

monthly_sales <- aggregate(
  Sales ~ Month,
  data = clean_data,
  FUN = sum
)

monthly_sales <- monthly_sales[
  order(monthly_sales$Month),
]

# Fill missing months with zero sales

all_months <- seq(
  min(monthly_sales$Month),
  max(monthly_sales$Month),
  by = "month"
)

monthly_sales <- merge(
  data.frame(Month = all_months),
  monthly_sales,
  by = "Month",
  all.x = TRUE
)

monthly_sales$Sales[
  is.na(monthly_sales$Sales)
] <- 0

monthly_sales <- monthly_sales[
  order(monthly_sales$Month),
]

cat("\nMonthly sales data:\n")
print(monthly_sales)

write.csv(
  monthly_sales,
  file.path(dirname(file_path), "Monthly_Sales.csv"),
  row.names = FALSE
)


# 6. VISUALIZE HISTORICAL SALES

p1 <- ggplot(
  monthly_sales,
  aes(x = Month, y = Sales)
) +
  geom_line() +
  geom_point() +
  labs(
    title = "Historical Monthly Sales",
    x = "Month",
    y = "Sales"
  ) +
  theme_minimal()

print(p1)


# 7. CONVERT DATA INTO TIME SERIES

n <- nrow(monthly_sales)

if (n < 24) {
  stop(
    "At least 24 months of data are recommended. ",
    "This dataset has fewer observations."
  )
}

start_year <- as.integer(
  format(monthly_sales$Month[1], "%Y")
)

start_month <- as.integer(
  format(monthly_sales$Month[1], "%m")
)

sales_ts <- ts(
  monthly_sales$Sales,
  start = c(start_year, start_month),
  frequency = 12
)

plot(
  sales_ts,
  main = "Monthly Sales Time Series",
  xlab = "Year",
  ylab = "Sales"
)


# 8. SPLIT INTO TRAINING AND TESTING DATA

h <- min(12, max(3, floor(n * 0.20)))

train_sales <- monthly_sales$Sales[1:(n-h)]

test_sales <- monthly_sales$Sales[
  (n-h+1):n
]

train_months <- monthly_sales$Month[1:(n-h)]

test_months <- monthly_sales$Month[
  (n-h+1):n
]

train_ts <- ts(
  train_sales,
  start = c(
    start_year,
    start_month
  ),
  frequency = 12
)

cat("\nTraining observations:", length(train_sales))
cat("\nTesting observations:", length(test_sales), "\n")


# 9. IMPLEMENT FORECASTING ALGORITHMS

predictions <- list()


# MODEL 1: ARIMA

model_arima <- auto.arima(
  train_ts,
  seasonal = TRUE
)

forecast_arima <- forecast(
  model_arima,
  h = h
)

predictions$ARIMA <- as.numeric(
  forecast_arima$mean
)


# MODEL 2: HOLT-WINTERS / ETS

model_ets <- ets(train_ts)

forecast_ets <- forecast(
  model_ets,
  h = h
)

predictions$ETS <- as.numeric(
  forecast_ets$mean
)


# MODEL 3: SEASONAL NAIVE

forecast_naive <- snaive(
  train_ts,
  h = h
)

predictions$Seasonal_Naive <- as.numeric(
  forecast_naive$mean
)


# MODEL 4: LINEAR REGRESSION

regression_data <- data.frame(
  Sales = train_sales,
  Trend = seq_along(train_sales),
  Month = factor(
    format(train_months, "%m"),
    levels = sprintf("%02d", 1:12)
  )
)

model_lm <- lm(
  Sales ~ Trend + Month,
  data = regression_data
)

future_regression <- data.frame(
  Trend = (length(train_sales)+1):(length(train_sales)+h),
  Month = factor(
    format(test_months, "%m"),
    levels = sprintf("%02d", 1:12)
  )
)

predictions$Linear_Regression <- as.numeric(
  predict(model_lm, newdata = future_regression)
)


# 10. MODEL EVALUATION

calculate_metrics <- function(actual, predicted) {

  MAE <- mean(abs(actual - predicted))

  RMSE <- sqrt(
    mean((actual - predicted)^2)
  )

  nonzero <- actual != 0

  MAPE <- if (any(nonzero)) {
    mean(
      abs(
        (actual[nonzero] - predicted[nonzero]) /
          actual[nonzero]
      )
    ) * 100
  } else {
    NA_real_
  }

  return(c(
    MAE = MAE,
    RMSE = RMSE,
    MAPE = MAPE
  ))
}

comparison <- do.call(
  rbind,
  lapply(names(predictions), function(model_name) {

    calculate_metrics(
      test_sales,
      predictions[[model_name]]
    )
  })
)

comparison <- data.frame(
  Algorithm = names(predictions),
  comparison,
  row.names = NULL
)

cat("\nMODEL PERFORMANCE COMPARISON\n")
print(comparison)

write.csv(
  comparison,
  file.path(dirname(file_path), "Model_Comparison.csv"),
  row.names = FALSE
)


# 11. SELECT BEST-PERFORMING MODEL

best_index <- which.min(comparison$RMSE)

best_algorithm <- comparison$Algorithm[best_index]

cat("\nBest Algorithm:", best_algorithm, "\n")


# 12. PLOT ACTUAL VS PREDICTED SALES

comparison_plot <- do.call(
  rbind,
  lapply(names(predictions), function(model_name) {

    data.frame(
      Month = test_months,
      Predicted = predictions[[model_name]],
      Algorithm = model_name
    )
  })
)

p2 <- ggplot() +
  geom_line(
    data = data.frame(
      Month = test_months,
      Sales = test_sales
    ),
    aes(x = Month, y = Sales),
    color = "black",
    linewidth = 1
  ) +
  geom_line(
    data = comparison_plot,
    aes(
      x = Month,
      y = Predicted,
      color = Algorithm
    ),
    linewidth = 0.8
  ) +
  labs(
    title = "Actual vs Predicted Sales",
    x = "Month",
    y = "Sales"
  ) +
  theme_minimal()

print(p2)


# 13. FORECAST NEXT 12 MONTHS USING BEST MODEL

future_h <- 12

if (best_algorithm == "ARIMA") {

  final_model <- auto.arima(sales_ts)

  final_forecast <- forecast(
    final_model,
    h = future_h,
    level = 95
  )

  future_values <- as.numeric(final_forecast$mean)
  lower_values <- as.numeric(final_forecast$lower[, 1])
  upper_values <- as.numeric(final_forecast$upper[, 1])

} else if (best_algorithm == "ETS") {

  final_model <- ets(sales_ts)

  final_forecast <- forecast(
    final_model,
    h = future_h,
    level = 95
  )

  future_values <- as.numeric(final_forecast$mean)
  lower_values <- as.numeric(final_forecast$lower[, 1])
  upper_values <- as.numeric(final_forecast$upper[, 1])

} else if (best_algorithm == "Seasonal_Naive") {

  final_model <- snaive(sales_ts)

  final_forecast <- forecast(
    final_model,
    h = future_h,
    level = 95
  )

  future_values <- as.numeric(final_forecast$mean)
  lower_values <- as.numeric(final_forecast$lower[, 1])
  upper_values <- as.numeric(final_forecast$upper[, 1])

} else {

  final_model <- lm(
    Sales ~ Trend + Month,
    data = data.frame(
      Sales = monthly_sales$Sales,
      Trend = seq_len(n),
      Month = factor(
        format(monthly_sales$Month, "%m"),
        levels = sprintf("%02d", 1:12)
      )
    )
  )

  future_months <- seq(
    max(monthly_sales$Month),
    by = "month",
    length.out = future_h + 1
  )[-1]

  future_data <- data.frame(
    Trend = (n+1):(n+future_h),
    Month = factor(
      format(future_months, "%m"),
      levels = sprintf("%02d", 1:12)
    )
  )

  regression_forecast <- predict(
    final_model,
    newdata = future_data,
    interval = "prediction",
    level = 0.95
  )

  future_values <- regression_forecast[, "fit"]
  lower_values <- regression_forecast[, "lwr"]
  upper_values <- regression_forecast[, "upr"]
}


# 14. GENERATE FUTURE FORECAST TABLE

future_months <- seq(
  max(monthly_sales$Month),
  by = "month",
  length.out = future_h + 1
)[-1]

future_sales <- data.frame(
  Month = future_months,
  Predicted_Sales = round(future_values, 2),
  Lower_95 = round(lower_values, 2),
  Upper_95 = round(upper_values, 2)
)

cat("\nNEXT 12 MONTHS SALES FORECAST\n")
print(future_sales)

write.csv(
  future_sales,
  file.path(dirname(file_path), "Future_Sales_Forecast.csv"),
  row.names = FALSE
)


# 15. VISUALIZE FUTURE FORECAST

p3 <- ggplot() +

  geom_line(
    data = monthly_sales,
    aes(x = Month, y = Sales),
    color = "black"
  ) +

  geom_ribbon(
    data = future_sales,
    aes(
      x = Month,
      ymin = Lower_95,
      ymax = Upper_95
    ),
    alpha = 0.2
  ) +

  geom_line(
    data = future_sales,
    aes(
      x = Month,
      y = Predicted_Sales
    ),
    color = "blue",
    linewidth = 1
  ) +

  labs(
    title = paste(
      "12-Month Sales Forecast Using",
      best_algorithm
    ),
    x = "Month",
    y = "Sales"
  ) +

  theme_minimal()

print(p3)


# 16. FINAL OUTPUT

cat("\n====================================\n")
cat("SALES FORECASTING COMPLETED!\n")
cat("====================================\n")

cat("\nBest Algorithm:", best_algorithm)

cat("\nFiles generated:")
cat("\n1. Monthly_Sales.csv")
cat("\n2. Model_Comparison.csv")
cat("\n3. Future_Sales_Forecast.csv")

cat("\n\nAll files are saved beside your original dataset.\n")
