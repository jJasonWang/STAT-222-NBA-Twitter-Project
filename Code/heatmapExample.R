library(ggplot2)
library(reshape2)

m <- matrix(sample(c(TRUE, FALSE), 9, replace=TRUE), ncol=3)
df <- melt(m)

ggplot(df, aes(x=Var1, y=Var2, fill=value)) + geom_tile()
