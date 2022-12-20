library(rjson)
js <- fromJSON(file = "measurement.json")
df <- as.data.frame(js)
df <- df[,c("phone_number", "age", "gender", "full_name", "sensors.name", "sensors.data", "sensors.unit_of_measurement"
      ,"sensors.name.1", "sensors.data.1", "sensors.unit_of_measurement.1"
      ,"sensors.name.2", "sensors.data.2", "sensors.unit_of_measurement.2"
      ,"sensors.name.3", "sensors.data.3", "sensors.unit_of_measurement.3")]

# simulating random data
# simulation of 1000 registers, which will correspond to the last 1000 measurements

## sugar levels simulation
## decided to generate random data following a normal distribution with mean of 120 and a standard deviation of 40
### ref: https://www.healthline.com/health/diabetes/blood-sugar-level-chart#recommended-ranges
sim_gc <- rnorm(1000, mean = 120, sd = 40)
hist(sim_gc, xlab = "Glucose levels", main = "Histogram of Glucose levels")

## blood pressure
## decided to generate random data following a normal distribution with mean of 110 and a standard deviation of 15
### ref: https://www.emedicinehealth.com/what_is_a_normal_blood_pressure_range_by_age/article_em.htm
sim_bp <- rnorm(1000, mean = 110, sd = 15)
hist(sim_bp, xlab = "Blood pressure", main = "Histogram of Blood pressure")

## heart rate
## decided to generate random data following a normal distribution with mean of 40 and a standard deviation of 10
### ref: https://www.whoop.com/thelocker/normal-hrv-range-age-gender/
sim_hr <- rnorm(1000, mean = 40, sd = 10)
hist(sim_hr, xlab = "Heart rate", main = "Histogram of Heart rate")

## oxygen in blood
## decided to generate random data following a normal distribution with mean of 96 and a standard deviation of 3
### ref: https://www.emedicinehealth.com/what_is_a_good_oxygen_rate_by_age/article_em.htm
sim_ob <- rnorm(1000, mean = 96, sd = 3)
hist(sim_ob, xlab = "Oxygen in blood", main = "Histogram of Oxygen in blood")


# let's create a data set with the generated data as a replacement for the historic of the patient that we don't have
historic <- data.frame(
  "glucose levels (mg/dl)" = sim_gc
  ,"blood pressure (mm/Hg)" = sim_bp
  ,"heart rate (HRV)" = sim_hr
  ,"oxygen levels (HRV)" = sim_ob
  ,check.names=FALSE
)

# since this is a device for diabetic people, let's study if there is any correlation between the glucose levels and the other variables
# this is done performing Hypothesis Testing, where null hypothesis H0 is not being correlation and the alternative hypothesis H1 is being correlation
# between variables

# for glucose levels and blood pressure
plot(historic$`glucose levels (mg/dl)`, historic$`blood pressure (mm/Hg)`,
     xlab = "Glucose levels", ylab = "Blood pressure",
     main = "Glcuose levels vs Blood pressure")
test_gc <- cor.test(historic$`glucose levels (mg/dl)`, historic$`blood pressure (mm/Hg)`)
print(test_gc)
# The correlation coefficient between the two vectors turns out to be
print(test_gc$estimate)
# A positive correlation would be near 1, a negative one near -1, and no correlation near 0.
# The p-value is 
print(test_gc$p.value)
# higher than 0.05, so we decide to believe that we cannot fail to reject the null hypothesis, hence there is no correlation between
# the glucose levels and the blood pressure

# for glucose levels and heart rate
plot(historic$`glucose levels (mg/dl)`, historic$`heart rate (HRV)`,
     xlab = "Glucose levels", ylab = "Heart rate",
     main = "Glcuose levels vs Heart rate")
test_hr <- cor.test(historic$`glucose levels (mg/dl)`, historic$`heart rate (HRV)`)
# The correlation coefficient between the two vectors turns out to be
print(test_hr$estimate)
# The p-value is 
print(test_hr$p.value)
# higher than 0.05, so we decide to believe that we cannot fail to reject the null hypothesis, hence there is no correlation between
# the glucose levels and the heart rate

# for glucose levels and oxygen levels
plot(historic$`glucose levels (mg/dl)`, historic$`oxygen levels (HRV)`,
     xlab = "Glucose levels", ylab = "Oxygen in blood",
     main = "Glcuose levels vs Oxygen in blood")
test_ol <- cor.test(historic$`glucose levels (mg/dl)`, historic$`oxygen levels (HRV)`)
# The correlation coefficient between the two vectors turns out to be
print(test_ol$estimate)
# The p-value is
print(test_ol$p.value)
# higher than 0.05, so we decide to believe that we cannot fail to reject the null hypothesis, hence there is no correlation between
# the glucose levels and the oxygen levels


# for the new measurements we will be checking that there is nothing abnormal and in case there were we could take actions to prevent unwanted situations
# since every person has different values, for the user Josefina Ludios we will create a 95% confidence interval. 

# length of the historic
n <- length(historic$`glucose levels (mg/dl)`)

# calculate t-value for 99% confidence
alpha = 0.01
degrees_of_freedom = n - 1
t_score = qt(p=alpha/2, df=degrees_of_freedom,lower.tail=F)

# confidence interval for glucose levels
X <- mean(historic$`glucose levels (mg/dl)`)
sd <- sd(historic$`glucose levels (mg/dl)`)
std_error <- sd / sqrt(n)
margin_error <- t_score * std_error
up_bound_gc <- X + margin_error
low_bound_gc <- X - margin_error
print(c(low_bound_gc, X, up_bound_gc))

# check if new input value is in the normal values of the user
if (df$sensors.data < low_bound_gc || df$sensors.data > up_bound_gc) print("You should check your glucose levels!")

# confidence interval for blood pressure
X <- mean(historic$`blood pressure (mm/Hg)`)
sd <- sd(historic$`blood pressure (mm/Hg)`)
std_error <- sd / sqrt(n)
margin_error <- t_score * std_error
up_bound_bp <- X + margin_error
low_bound_bp <- X - margin_error
print(c(low_bound_bp, X, up_bound_bp))

# check if new input value is in the normal values of the user
if (df$sensors.data.1 < low_bound_bp || df$sensors.data.1 > up_bound_bp) print("You should check your blood pressure!")

# confidence interval for heart rate
X <- mean(historic$`heart rate (HRV)`)
sd <- sd(historic$`heart rate (HRV)`)
std_error <- sd / sqrt(n)
margin_error <- t_score * std_error
up_bound_hr <- X + margin_error
low_bound_hr <- X - margin_error
print(c(low_bound_hr, X, up_bound_hr))

# check if new input value is in the normal values of the user
if (df$sensors.data.2 < low_bound_hr || df$sensors.data.2 > up_bound_hr) print("You should check your heart rate!")

# confidence interval for oxygen levels
X <- mean(historic$`oxygen levels (HRV)`)
sd <- sd(historic$`oxygen levels (HRV)`)
std_error <- sd / sqrt(n)
margin_error <- t_score * std_error
up_bound_ol <- X + margin_error
low_bound_ol <- X - margin_error
print(c(low_bound_ol, X, up_bound_ol))

# check if new input value is in the normal values of the user
if (df$sensors.data.3 < low_bound_ol || df$sensors.data.3 > up_bound_ol) print("You should check your oxygen levels!")

# let's add the new values to the historic so we can do new computations
new_measurement <- c(df$sensors.data, df$sensors.data.1, df$sensors.data.2, df$sensors.data.3)
historic <- rbind(historic, new_measurement)

# Disclaimer: The data has been generated randomly and is not from a real patient, we do not take responsibility for a misuse of the data or the results in this script.