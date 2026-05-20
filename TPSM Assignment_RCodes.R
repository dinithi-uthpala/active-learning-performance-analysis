# =========================================================
# TPSM Assignment - Active Learning Engagement Analysis
# =========================================================

# 1. Set working directory and load dataset
setwd("C:\\Users\\ASUS\\Downloads")

df <- read.csv("cleaned_dataset.csv")

# 2. Check data
names(df)
str(df)
summary(df)

# 3. Convert variables to correct type
df$exam_score <- as.numeric(df$exam_score)
df$active_ratio <- as.numeric(df$active_ratio)

# 4. Rename learning group column
names(df)[5] <- "learning_group"

# 5. Create learning group using median split
median_value <- median(df$active_ratio, na.rm = TRUE)

df$learning_group <- ifelse(df$active_ratio >= median_value,
                            "Active",
                            "Passive")

df$learning_group <- factor(df$learning_group,
                            levels = c("Passive", "Active"))

# Check grouping
median_value
table(df$learning_group)

# =========================================================
# DESCRIPTIVE ANALYSIS
# =========================================================

# Summary statistics
summary(df$exam_score)
summary(df$active_ratio)

# Mean exam score by learning group
aggregate(exam_score ~ learning_group, data = df, mean)

# SD by learning group
aggregate(exam_score ~ learning_group, data = df, sd)

# Histogram - Exam Score
par(mfrow = c(1,1))
par(mar = c(5,4,4,2))

hist(df$exam_score,
     col = "lightblue",
     border = "gray40",
     main = "Distribution of Exam Scores",
     xlab = "Exam Score",
     ylab = "Frequency")

# Boxplot - Exam Score
boxplot(df$exam_score,
        col = "lightblue",
        main = "Boxplot for Exam Scores",
        ylab = "Exam Score")

# Histogram - Active Ratio
hist(df$active_ratio,
     col = "lightblue",
     border = "gray40",
     main = "Distribution of Active Ratio",
     xlab = "Active Ratio",
     ylab = "Frequency")

# Density Plot - Active Ratio
plot(density(df$active_ratio, na.rm = TRUE),
     main = "Density Plot for Active Ratio",
     xlab = "Active Ratio",
     ylab = "Density",
     col = "blue",
     lwd = 2)

# Scatter plot - Exam Score by Learner Type
plot(as.numeric(df$learning_group),
     df$exam_score,
     main = "Exam Score by Learner Type",
     xlab = "Learner Type",
     ylab = "Exam Score",
     col = rgb(0.2, 0.45, 0.6, 0.35),
     pch = 16,
     cex = 1.5,
     xaxt = "n")

axis(1, at = c(1, 2), labels = c("Passive", "Active"))
grid()

# Bar chart - Mean score by group
library(ggplot2)

ggplot(df, aes(x = learning_group, y = exam_score)) +
  stat_summary(fun = mean, geom = "bar", fill = "lightblue", width = 0.7) +
  labs(title = "Mean Exam Score by Learner Type",
       x = "Learner Type",
       y = "Mean Exam Score") +
  theme_minimal()

# =========================================================
# INFERENTIAL ANALYSIS
# =========================================================

# Welch Two Sample t-test
t_test_result <- t.test(exam_score ~ learning_group, data = df)

t_test_result

# Extract important values
t_test_result$estimate
t_test_result$statistic
t_test_result$p.value
t_test_result$conf.int

# CDF Plot
plot(ecdf(df$exam_score[df$learning_group == "Passive"]),
     col = "orange",
     lwd = 2,
     main = "CDF of Exam Scores by Learning Group",
     xlab = "Exam Score",
     ylab = "Cumulative Probability")

lines(ecdf(df$exam_score[df$learning_group == "Active"]),
      col = "blue",
      lwd = 2)

legend("bottomright",
       legend = c("Passive", "Active"),
       col = c("orange", "blue"),
       lwd = 2)

# Engagement Groups
df$engagement_group <- ifelse(df$active_ratio == 0, "No Activity",
                              ifelse(df$active_ratio <= quantile(df$active_ratio[df$active_ratio > 0], 0.33, na.rm = TRUE), "Low",
                                     ifelse(df$active_ratio <= quantile(df$active_ratio[df$active_ratio > 0], 0.67, na.rm = TRUE), "Medium",
                                            "High")))

df$engagement_group <- factor(df$engagement_group,
                              levels = c("No Activity", "Low", "Medium", "High"))

# Mean score by engagement group and learning group
ggplot(df, aes(x = engagement_group,
               y = exam_score,
               fill = learning_group)) +
  stat_summary(fun = mean,
               geom = "bar",
               position = "dodge") +
  scale_fill_manual(values = c("Passive" = "orange",
                               "Active" = "blue")) +
  labs(title = "Exam Score by Engagement Level and Learning Group",
       x = "Engagement Group",
       y = "Mean Exam Score",
       fill = "Group") +
  theme_minimal()

# =========================================================
# PREDICTIVE ANALYSIS
# =========================================================

# Linear regression model
model <- lm(exam_score ~ active_ratio, data = df)
summary(model)

# Regression with learning group
model_group <- lm(exam_score ~ active_ratio + learning_group, data = df)
summary(model_group)

# Prediction data
new_data <- expand.grid(
  active_ratio = seq(0, 1, length.out = 100),
  learning_group = levels(df$learning_group)
)

new_data$predicted_score <- predict(model_group, newdata = new_data)

# Predicted Exam Score by Engagement and Learning Group
ggplot(new_data, aes(x = active_ratio,
                     y = predicted_score,
                     color = learning_group)) +
  geom_line(size = 1.2) +
  scale_color_manual(values = c("Passive" = "orange",
                                "Active" = "blue")) +
  labs(title = "Predicted Exam Score by Engagement and Learning Group",
       x = "Active Ratio",
       y = "Predicted Exam Score",
       color = "Group") +
  theme_minimal()

# Regression scatter plot
ggplot(df, aes(x = active_ratio, y = exam_score)) +
  geom_point(alpha = 0.2, color = "grey") +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(title = "Regression: Active Engagement vs Exam Score",
       x = "Active Ratio",
       y = "Exam Score") +
  theme_minimal()

aggregate(exam_score ~ learning_group, data = df, mean)
