# -----------------------------
# Research Methods - R workshop
# -----------------------------
#
# 18 participants (9 female, 9 male) were given one of three possible dosages 
# of a drug. They were all tested on recall for three types of words (negative, 
# neutral, positive), using two distinct memory tasks.
#
# The data contains variables for:
#       - Gender: Female (F), Male (M)
#       - Dosage: A, B, C
#       - Task: Cued recall (C), Free recall (F)
#
# The scores for recall are shown for each category of word valence:
#       - Negative (neg), Neutral (neu), Positive (pos)
#
# In this workshop, you are asked to:
#       - Calculate the average scores for each dosage of the drug
#       - Create a histogram for the overall scores
#       - Assess the effects of gender, task, valence, and dosage on scores
#       - Plot the results
#
# You should expect to find the following results:
#       - Average scores:
#           - Dosage A: 14.19
#           - Dosage B: 13.5
#           - Dosage C: 19.19
#       - Main effects:
#           - Gender: F = 5.685, p = .034
#           - Task: F = 39.862, p < .001
#
# -----------------------
# Start your script below
# -----------------------

# Read data
data <- read.csv("r-workshop-data.csv")

# Convert data to long format
library(tidyr)
data.long <- gather(data, valence, recall, neg:pos)
data.long$valence <- as.factor(data.long$valence)

# Get average scores for each dosage
mean(data.long$recall[data.long$dosage == "A"])
mean(data.long$recall[data.long$dosage == "B"])
mean(data.long$recall[data.long$dosage == "C"])

# Histogram of recall
hist(data.long$recall)

# Parametric assumptions
shapiro.test(data.long$recall) 
## Result: p >= .05, so the scores are considered as normally distributed

# ANOVA (Method 1)
aov <- aov(recall ~ gender * dosage * task * valence + 
             Error(participant / task * valence), data = data.long)
summary(aov)
## Result: Main effects of gender and task, no interactions

# ANOVA (Method 2)
library(ez)
ezANOVA(data = data.long,
        dv = .(recall),
        wid = .(participant),
        within = .(task, valence),
        between = .(gender, dosage))
## Result: Main effects of gender and task, no interactions

# Plot (Method 1)
interaction.plot(data.long$task, data.long$gender, data.long$recall,
                 trace.label = "Gender",
                 xlab = "Task",
                 ylab = "Recall",
                 main = "Effects of task and gender on recall")

# Plot (Method 2)
boxplot(recall ~ task + gender, 
        data = data.long,
        names = c("Cued, Female", "Free, Female", "Cued, Male", "Free, Male"),
        xlab = "Task, Gender",
        ylab = "Recall",
        main = "Effects of task and gender on recall")
