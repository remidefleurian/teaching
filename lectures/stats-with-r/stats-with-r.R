# R SYNTAX ---------------------------------------------------------------------
# R objects
x <- 2

# Create data
d <- c(8, 3, 5, 2, 3)

# Generate data
x.random <- runif(30, min = 0, max = 10)
x.normal <- rnorm(30, mean = 10, sd = 3)

# Import data from csv
data <- read.csv("data/stats-with-r-data.csv")

# Create vector
v <- c(9, 3, 5, 6, 2)

# Third element of vector v
v[3]

# Create matrix 
m <- matrix(c(1:30), nrow = 6, ncol = 5, byrow = FALSE)

# Second column of matrix m
m[,2]

# Fourth line of matrix m
m[4,]

# Rows 2-4 of columns 1-3 or matrix m
m[2:4,1:3]

# Second column of data frame
data$Test_2

# Basic maths
1 + 2 * 3
2 * 5^2 - 10 * 5
4 * sin(pi / 2)

# for loop
for (year in c(2010:2018)){
  print(paste("The year is ", year, ".", sep = ""))
}

# if...else statement
x <- -5

if(x >= 0){
  print("Positive number")
} else {
  print("Negative number")
}

# Help
?mean
help(mean)
help.search('t-test')

# BASIC STATISTICS -------------------------------------------------------------
# Populate a data frame
data <- data.frame(
  gender = rbinom(150, 1, 0.5),
  age = runif(150, min = 21, max = 55),
  fav.colour = rep(c("blue", "red", "green"), 50),
  test.before = rnorm(150, mean = 46, sd = 15),
  test.during = rnorm(150, mean = 62, sd = 13),
  test.after = rnorm(150, mean = 60, sd = 16)
)

# Explore head and tail of data frame
head(data)
tail(data)

# Basic descriptive statistics
summary(data)
sd(data$test.before)

# More advanced descriptive statistics, with moments package
library(moments)
skewness(data$test.before)
kurtosis(data$test.before)

# Histogram
hist(data$test.before)

# Useful (but more advanced) bit of code, using ggplot2 package
library(ggplot2)
d <- data.frame(score = c(data$test.before, data$test.during, data$test.after),
                treatment=rep(c("before", "during", "after"),
                              c(length(data$test.before),
                                length(data$test.during),
                                length(data$test.after))))
ggplot(d) + 
  geom_density(aes(x=score, colour=treatment, fill=treatment), alpha=0.2)

# Normality (Shapiro-Wilk)
shapiro.test(data$age)
shapiro.test(data$test.before)

# Homogeneity of variance (for two-sample t-tests and ANOVAs)
var.test(data$age, data$test.before)
var.test(data$test.before, data$test.after)

# Crosstabs
tab <- xtabs(~gender + fav.colour, data = data)
ftable(tab)

# Parametric test (Chi-squared)
chisq.test(tab)

# Non-parametric test (Kruskal-Wallis)
kruskal.test(gender ~ fav.colour, data = data)

# Add a new variable to the dataframe
new.test <- (data$test.after + runif(length(data$test.after), min = -10, max = 10))
data <- cbind(data, new.test)

# Scatterplots are great to visualise correlation
plot(data$test.before, data$test.after)

# Titles and axis labels can easily be added
plot(data$test.after, data$new.test, 
     main = "Plot for scores on test after treatment and new test",
     xlab = "Scores after treatment",
     ylab = "Scores on new test")

# As well as a regression line
abline(lm(data$test.after ~ data$new.test))

# Parametric correlation test (Pearson)
cor.test(data$test.before, data$test.after, method="pearson")
cor.test(data$test.after, data$new.test, method="pearson")

# Non-parametric correlation test (Spearman)
cor.test(data$test.before, data$test.after, method="spearman")
cor.test(data$test.after, data$new.test, method="spearman")

# Parametric one-sample t-test
t.test(data$test.before, mu = 46)
t.test(data$test.before, mu = 50)

# Parametric two-sample t-test
t.test(data$test.before, data$test.during)
t.test(data$test.during, data$test.after)

# Parametric paired-sample t-test (more powerful)
t.test(data$test.during, data$test.after, paired = TRUE)

# Non-parametric tests (Mann-Whitney U or Wilcoxon)
wilcox.test(data$test.before, data$test.during)
wilcox.test(data$test.during, data$test.after)

# ANOVA ------------------------------------------------------------------------
# Between-subjects one-way ANOVA
aov1 <- aov(test.before ~ fav.colour, data = data)  # Build the model
summary(aov1)                                       # Show the ANOVA results
model.tables(aov1, "means")                         # Show the means
library(gplots)                                     # Plot the means          
plotmeans(data$test.before ~ data$fav.colour,
          xlab="Favourite colour",
          ylab="Test scores before treatment", 
          main="Mean plot with 95% CI")

# Between-subjects two-way ANOVA
data$gender <- factor(data$gender)                              # Ensure gender is a factor
aov2 <- aov(test.after ~ gender * fav.colour, data = data)      # Build the model
summary(aov2)                                                   # Show the ANOVA results
model.tables(aov2, "means")                                     # Show the means
TukeyHSD(aov2)                                                  # Post-hoc test
interaction.plot(data$gender, data$fav.colour, data$test.after, # Plot the means
                 trace.label="Gender",
                 xlab="Favourite colour",
                 ylab="Test scores after treatment",
                 main="Interaction plot")

# Format the data frame for within-subject ANOVAs
data <- cbind(participant = c(1:150), data)                         # Add participant number
library(tidyr)                                                      # Convert to long format
data.long <- gather(data, treatment, test.score, test.before:new.test)

# Within-subject one-way ANOVA
data.long$participant <- factor(data.long$participant)              # Participant as factor
data.long$gender <- factor(data.long$gender)                        # Gender as factor
aov3 <- aov(test.score ~ treatment + Error(participant/treatment),  # Build the model 
            data = data.long)
summary(aov3)                                                       # Show the ANOVA results
model.tables(aov3, "means")                                         # Show the means
plotmeans(data.long$test.score ~ data.long$treatment,               # Plot the means
          xlab="Treatment",
          ylab="Test scores",
          main="Mean plot with 95% CI")

# Mixed-design ANOVA
aov4 <- aov(test.score ~ gender * treatment + Error(participant/treatment),   # Build model
            data = data.long)
summary(aov4)                                                                 # Show results
model.tables(aov4, "means")                                                   # Show means
interaction.plot(data.long$treatment, data.long$gender, data.long$test.score, # Plot means
                 trace.label="Gender",
                 xlab="Treatment",
                 ylab="Test scores",
                 main="Interaction plot")

# ANOVAs with ezANOVA
library(ez)
ezANOVA(data = data.long,                 # Data frame
        dv = .(test.score),               # Dependent variable
        wid = .(participant),             # Participant number
        within = .(treatment),            # Within-subject factor
        between = .(gender, fav.colour))  # Between-subject factors

# MODELLING --------------------------------------------------------------------
# Populate a data frame
alligator = data.frame(
  length = c(3.87, 3.61, 4.33, 3.43, 3.81, 3.83, 3.46, 3.76, 
             3.50, 3.58, 4.19, 3.78, 3.71, 3.73, 3.78), 
  weight = c(4.87, 3.93, 6.46, 3.33, 4.38, 4.70, 3.50, 4.50,
             3.58, 3.64, 5.90, 4.43, 4.38, 4.42, 4.25))

# Plot relationship between the two variables
plot(alligator$length, alligator$weight, 
     xlab = "Length", 
     ylab = "Weight", 
     main = "Alligators")

# Fit linear model
model = lm(weight ~ length, data = alligator)
summary(model)

# Plot residuals
plot(resid(model) ~ fitted(model),
     xlab = "Fitted Values",
     ylab = "Residuals",
     main = "Residual Diagnostic Plot")
abline(h = 0)

# Explore residuals
hist(resid(model))
qqnorm(resid(model))
shapiro.test(resid(model))

# Make predictions on new data
new.data <- data.frame(length = c(3.27, 3.81, 4.32))
predict(model, new.data)
