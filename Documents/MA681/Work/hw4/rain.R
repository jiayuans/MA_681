library(ggplot2)
setwd("/Users/jiayuan/Documents/MA681/hw4")
data <- read.csv("illinois rain 1960-1964.csv",header=F)
data1 <- unlist(data)
head(data1)
tail(data1)

data1 <- data.frame(data1[1:227])
colnames(data1) <- "x"
class(x)

qplot(x, data=data1, geom = "histogram",binwidth=.15)

##  Now using the MGF for gamme or be simply looking it up
##  use the following facts about the gamma function 
##
##  firt moment = m1 = (alpha/lambda)
##  second moment = m2 = m1^2 + (m1/lambda)
##  from with you get equations for alpha and labda in terms of the moments
##  lambda = m1 / (m2 - m1^2)     note that (m2 - m1^2) = variance(x)
##  alpha = (m1^2)/(m2 - mx^2)
##  Now use the sample statistics X-bar and S-squared to estimate lambda and alpha
## lambda-hat = X-bar/S-squre
## alpha-hat =  (X-bar)^2 / S-square
##  So here are the calculations:

mean(data1$x)
var(data1$x)
alpha <- mean(data1$x)^2/var(data1$x)  # 0.376
lambda <- mean(data1$x)/var(data1$x)   # 1.677

# Homework #1:  Now make a plot ths superimposes the gamma density with the alpha and lambda as above
# on the histogram of the data.
# 
# see http://www.cookbook-r.com/Graphs/Plotting_distributions_(ggplot2)/
# for instructions on how to plot

## Of course, you now want to know how close these estimates are so ... 
ggplot(data1, aes(x=data1$x)) + 
  geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                 binwidth=.5,
                 colour="black", fill="white") +
  geom_density(alpha=.2, fill="#FF6666")  # Overlay with transparent density plot


## 
## homework # 2
## bootstrap -- samples (n=227) from gamma(alpha, lambda)
## to find the variance for the estimates of alpha and lambda
## state confidence for your estimates.  State why you picked 
## the estimator you used for the confidence interval.
## 

n<-227
x<-rgamma(n, shape=alpha, rate = lambda)
x
mu.hat<-mean(x)
sigma2.hat<-var(x)
t.alpha<-mu.hat^2/sigma2.hat
t.alpha
t.lambda<-mu.hat/sigma2.hat
t.lambda
B <- 1000
tboot.alpha <- rep(0,B)
tboot.lambda <- rep(0,B)
for(i in 1:B){
  x.s <- sample(x, n, replace=TRUE)
  tboot.alpha[i]<-mean(x.s)^2/var(x.s)
  tboot.lambda[i]<-mean(x.s)/var(x.s)
}
var(tboot.alpha)
var(tboot.lambda)
se.alpha <- sqrt(var(tboot.alpha))
se.lambda <- sqrt(var(tboot.lambda))
se.alpha
se.lambda

Percentile.alpha <- c(quantile(tboot.alpha,.025),quantile(tboot.alpha,.975))
pivotal.alpha <- c((2*t.alpha - quantile(tboot.alpha, .975)),(2*t.alpha - quantile(tboot.alpha, .025))) 

Percentile.lambda <- c(quantile(tboot.lambda,.025),quantile(tboot.lambda,.975))
pivotal.lambda <- c((2*t.lambda - quantile(tboot.lambda, .975)),(2*t.lambda - quantile(tboot.lambda, .025))) 

cat("Method       95% Interval\n")
cat("Percentile     (", Percentile.alpha[1], ",     ", Percentile.alpha[2], ") \n")
cat("Pivotal  (", pivotal.alpha[1], ",    ", pivotal.alpha[2], ") \n")

cat("Method       95% Interval\n")
cat("Percentile     (", Percentile.lambda[1], ",     ", Percentile.lambda[2], ") \n")
cat("Pivotal  (", pivotal.lambda[1], ",    ", pivotal.lambda[2], ") \n")

###################
##  to get read for the max likelihood estimation
##  tryout the function we're going to use

# try nlminb -- notice how it takes a function to optimize (minimize)
# examine the result

func <- function(y){(y[1]-3)^2 + (y[2]+1)^2}
min.func <- nlminb(start=c(1,1), obj= func)
min.func$par

# comes up with the obvious answer
# now lets use it to get max likelihood
x1 <- data1$x
n <- length(data1$x)
# remember we know how to MINIMIZE so
# setup theta <- c(alpha,lambda)
# and 

minus.likelihood <- function(theta) {-(n*theta[1]*log(theta[2])-n*lgamma(theta[1])+(theta[1]-1)*sum(log(x1))-theta[2]*sum(x1))}
max.likelihood <- nlminb(start=c(.3762, 1.6767), obj = minus.likelihood)
max.likelihood$par #0.4407914 1.9643791

# Homework # 3
# Justify the minus.likelihood fuction used above.  Note the use of "lgamma."
# 
# once you have solutions you believe, 
# bootstrap to get standard errors for alpha and lambda
# and produce an extimated confidence interval
# 
# Use this case to build a an illustrated guide to this kind of estimation. 
# The homework assignments will be part of this guide, but go beyond that to
# make a resource for yourself.


n<-227
x<-rgamma(n, shape=alpha, rate = lambda)
x
minus.likelihood <- function(theta){
  -(n*theta[1]*log(theta[2])-n*lgamma(theta[1])+
      (theta[1]-1)*sum(log(x1))-theta[2]*sum(x1))
}
max.likelihood <- nlminb(start=c(.3762, 1.6767), obj = minus.likelihood)
para<-max.likelihood$par
t.alpha<-para[1]
t.alpha
t.lambda<-para[2]
t.lambda
B <- 1000
tboot.alpha <- rep(0,B)
tboot.lambda <- rep(0,B)
for(i in 1:B){
  x.s <- sample(x, n, replace=TRUE)
  minus.likelihood <- function(theta) {
    -(n*theta[1]*log(theta[2])-n*lgamma(theta[1])+
        (theta[1]-1)*sum(log(x.s))-theta[2]*sum(x.s))}
  alpha1<-mean(x.s)^2/var(x.s)
  lambda1<-mean(x.s)/var(x.s)
  max.likelihood <- nlminb(start=c(alpha1, lambda1), obj = minus.likelihood)
  tboot.alpha[i]<-max.likelihood$par[1]
  tboot.lambda[i]<-max.likelihood$par[2]
}
var(tboot.alpha)
var(tboot.lambda)
se.alpha <- sqrt(var(tboot.alpha))
se.lambda <- sqrt(var(tboot.lambda))
se.alpha
se.lambda

Percentile.alpha <- c(quantile(tboot.alpha,.025),quantile(tboot.alpha,.975))
pivotal.alpha <- c((2*t.alpha - quantile(tboot.alpha, .975)),(2*t.alpha - quantile(tboot.alpha, .025))) 

Percentile.lambda <- c(quantile(tboot.lambda,.025),quantile(tboot.lambda,.975))
pivotal.lambda <- c((2*t.lambda - quantile(tboot.lambda, .975)),(2*t.lambda - quantile(tboot.lambda, .025))) 

cat("Method       95% Interval\n")
cat("Percentile     (", Percentile.alpha[1], ",     ", Percentile.alpha[2], ") \n")
cat("Pivotal  (", pivotal.alpha[1], ",    ", pivotal.alpha[2], ") \n")

cat("Method       95% Interval\n")
cat("Percentile     (", Percentile.lambda[1], ",     ", Percentile.lambda[2], ") \n")
cat("Pivotal  (", pivotal.lambda[1], ",    ", pivotal.lambda[2], ") \n")

