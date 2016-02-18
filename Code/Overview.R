setwd("../Desktop/")
data <- read.csv("rank.csv", stringsAsFactors=FALSE, header=FALSE)
library(ggplot2)

data$V1 <- factor(data$V1, levels=data$V1)

# Function change the format of y axis
change_format <- function(l) {
  # turn in to character string in scientific notation
  l <- format(l, scientific = TRUE)
  l <- sapply(l, function(x) strsplit(x, "e")[[1]][1])
  # return this as an expression
  parse(text=l)
}

ggplot(data, aes(x=V1, weight=V2)) + geom_bar() +
  scale_y_continuous(labels=change_format) + 
  labs(title="Title", x="Team", y="Number of Followers (Millions)") +
  theme(plot.title=element_text(size=25, face="bold"),
        axis.text.x=element_text(size=12),
        axis.text.y=element_text(size=12),
        axis.title=element_text(size=15, face="bold"))

data1 <- read.csv("time.csv", stringsAsFactors=FALSE, header=FALSE)
data1$V1 <- strptime(data1$V1, "%Y/%m/%d")

g1 <- ggplot(data1, aes(x=V1, y=V2)) + geom_line() +
  labs(title="Title", x="Time", y="y label") +
  theme(plot.title=element_text(size=25, face="bold"),
        axis.text.x=element_text(size=12),
        axis.text.y=element_text(size=12),
        axis.title=element_text(size=15, face="bold"))

# First Event
df <- data.frame(x2=as.POSIXct("2015-11-1"),
                 y2=3800,
                 x1=as.POSIXct("2015-11-7"),
                 y1=3500)

g2 <- g1 + geom_curve(data=df, aes(x=x1, y=y1, xend=x2, yend=y2),
                arrow=arrow(length=unit(0.3, "cm")), color="#619CFF") +
    geom_text(aes(x=as.POSIXct("2015-11-7"), y=3400, label="First Event"),
              color="#619CFF")

df2 <- data.frame(x2=as.POSIXct("2015-12-2"),
                 y2=2600,
                 x1=as.POSIXct("2015-12-8"),
                 y1=2500)

g3 <- g2 + geom_curve(data=df2, aes(x=x1, y=y1, xend=x2, yend=y2),
                      arrow=arrow(length=unit(0.3, "cm")), color="#619CFF") +
    geom_text(aes(x=as.POSIXct("2015-12-15"), y=2400, label="Second Event"),
              color="#619CFF")
