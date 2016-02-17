#setwd("~/Documents/Berkeley/Stat222/TwitterProject")
hashtags=read.csv("hashtags.csv",stringsAsFactors = FALSE, header=FALSE)
#install.packages("devtools")
library("devtools")
#install_github("arcdiagram",username="gastonstat")
library("arcdiagram")

hashtags=as.matrix(hashtags)
length(hashtags)

plt_arc <- function(ht_mat) {
  g_ht_mat <- graph.edgelist(ht_mat, directed = TRUE)
  mat_degree <- degree(g_ht_mat)
  gclus <- clusters(g_ht_mat)
  cols <- sample(colors(), 18, replace = FALSE)
  arcplot(ht_mat, lwd.arcs = mat_degree, cex.nodes = mat_degree/11, 
          show.nodes = TRUE, cex.labels = 0.5,
          col.nodes = cols,
          ordering = order(gclus$membership))
}

plt_arc(hashtags)