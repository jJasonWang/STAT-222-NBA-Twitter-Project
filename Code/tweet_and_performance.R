setwd("../Desktop/STAT 222/Twitter/")
library(dplyr)
library(reshape2)
library(ggplot2)
library(gridExtra)

##########Preprocessing##########
# Read data
tweet <- read.csv("Data/tweet_data.csv", stringsAsFactors=FALSE)
tweet$time <- strptime(tweet$created_time, "%Y-%m-%d")

account <- read.csv("Data/tweet_account_final.csv",
                    stringsAsFactors=FALSE)

NBA <- read.csv("Data/NBA_2016.csv", stringsAsFactors=FALSE)

# Merge tweet and account
tweet_account <- merge(tweet, account, by.x="screen_name",
                       by.y="Twitter", all.x=TRUE)
  
# Select column we need 
NBA_less <- NBA %>%
  select(Player, Pos, Age, G, GS, MP, X3P, X3PA, X2P, X2PA,
         FT, FTA, ORB, DRB, AST, STL, BLK, TOV, PF, PTS)

# Final data
tweet_NBA <- merge(tweet_account, NBA_less,
      by.x="Player", by.y="Player", all.x=TRUE)

# Output tweet_NBA.csv
write.csv(tweet_NBA, "tweet_NBA.csv")


##########Analysis##########
tweet_NBA <- read.csv("Data/tweet_NBA.csv", stringsAsFactors=FALSE)

# Order by player name and team
tweet_NBA <- tweet_NBA %>% arrange(Player) %>% arrange(Tm)

#----------First----------
# Preprocessing
# Retrieve attributes we need
X <- tweet_NBA[setdiff(names(tweet_NBA),
                       c("Player", "screen_name", "created_time",
                         "Tm", "Pos", "year", "Age", "favorites"))]

row.names(X) <- tweet_NBA$Player

# Correlation matrix
cor_mat <- cor(X)
# Change it into a long format data.frame
cor_df <- melt(cor_mat)

# Adjust the order of factor for better visualization
cor_df$Var1 <- factor(as.character(cor_df$Var1), levels=rev(names(X)))

##########Figure1: Correlation matrix##########
g1 <- ggplot(cor_df, aes(x=Var1, y=Var2, fill=value)) +
  geom_tile() + coord_flip() +
  scale_fill_distiller(palette="RdBu", limit=c(-1, 1)) + 
  labs(title="Correlation matrix", x="", y="") +
  theme(axis.text.x=element_text(angle=30, vjust=0.8, size=15),
        axis.text.y=element_text(size=20),
        plot.title=element_text(size=25, face="bold"),
        legend.text=element_text(size=12),
        legend.title=element_text(size=15))

g1

#----------Second----------
#Divided turnover into 3 categories.
tweet_NBA$TOV2 <- cut(tweet_NBA$TOV, c(0, 50, 100, Inf),
                      include.lowest=TRUE)

##########Figure2: Points, turnovers, follower##########
g2 <- ggplot(tweet_NBA, aes(x=PTS, y=log(followers), color=TOV2)) +
  geom_point(size=3) +
  geom_smooth(data=tweet_NBA, aes(x=PTS, y=log(followers), group=1)) +
  scale_color_discrete("Turnover",
                       breaks= c("[0,50]", "(50,100]", "(100,Inf]"),
                       labels=c("< 50", "50 ~ 100", "> 100")) + 
  labs(title="Followers(log scale) v.s. Points",
       x="Points", y=expression(log(Followers))) +
  theme(axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=13),
        axis.title.x=element_text(size=20),
        axis.title.y=element_text(size=20),
        plot.title=element_text(size=25, face="bold"),
        legend.title=element_text(size=17),
        legend.text=element_text(size=12))

g2

#----------Third----------
#Divided game started into three categories
tweet_NBA$GSP <- cut(tweet_NBA$GS/tweet_NBA$G,
                     c(0, 0.25, 0.75, 1), include.lowest=TRUE)

# Find the player with most followers in each group
top <- tweet_NBA %>%
  group_by(GSP) %>%
  select(Player, GSP, followers) %>%
  arrange(desc(followers)) %>%
  top_n(1)

##########Figure3: Followers and Game Started proportion##########
g3 <- ggplot(tweet_NBA, aes(x=GSP, y=log(followers), fill=GSP)) + geom_boxplot() + 
  scale_x_discrete(breaks=c("[0,0.25]", "(0.25,0.75]", "(0.75,1]"),
                   labels=c("Bench", "Middle", "Starter")) +
  scale_fill_manual("Proportion\n    of\nGame Statred",
                    values=c("darkorange", "seagreen", "dodgerblue"),
                    breaks=c("[0,0.25]", "(0.25,0.75]", "(0.75,1]"),
                    labels=c("< 0.25", "0.25 ~ 0.75", "> 0.75")) + 
  labs(title="Followers v.s. Game Started Proportion", x="", y=expression(log(Followers))) +
  theme(axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=15),
        axis.title.x=element_text(size=15),
        axis.title.y=element_text(size=20),
        plot.title=element_text(size=25, face="bold"),
        legend.title=element_text(size=17),
        legend.text=element_text(size=12))

g3 + geom_text(data=top, aes(x=GSP, y=log(followers), label=Player),
               vjust=-0.7, size=5)


#----------Fourth----------
# Read the data with number of follower in team
follower <- read.csv("Data/player_follow.csv", stringsAsFactors=FALSE)

# Merge two dataset
tweet_follow <- merge(follower, tweet_NBA, all.x=TRUE)

# Divided into three categories
tweet_follow$followers_team <- cut(tweet_follow$followers_in_team,
                                   c(0, 3, 7, Inf), include.lowest=TRUE)

##########Figure4: Number of teammate following, assit, minute played##########
g41 <- ggplot(tweet_follow, aes(x=log(AST), y=MP, color=followers_team)) +
  geom_point(size=3) +
  labs(x=expression(log(Assists)), y="Minutes Played") +
  theme(legend.position="none",
        axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=13),
        axis.title.x=element_text(size=20),
        axis.title.y=element_text(size=20))

g42 <- ggplot(tweet_follow, aes(x=MP, fill=followers_team, color=followers_team)) +
  geom_density(alpha=0.5) +
  scale_fill_discrete("# of\nfollower\nin team",
                      breaks=c("[0,3]", "(3,7]", "(7,Inf]"),
                      labels=c("< 3", "3 ~ 7", "> 7")) + 
  coord_flip() + labs(x="") +
  scale_color_discrete(guide=FALSE) + 
  theme(axis.text.x=element_text(size=13, vjust=0.5),
        axis.text.y=element_text(size=13),
        axis.title.x=element_text(size=20),
        legend.title=element_text(size=17),
        legend.text=element_text(size=12))

g43 <- ggplot(tweet_follow, aes(x=log(AST), fill=followers_team, color=followers_team)) +
  geom_density(alpha=0.5) + labs(x="") + 
  theme(legend.position="none",
        axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=13),
        axis.title.y=element_text(size=20))

# Function return the legend of a ggplot object
g_legend <- function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

grid.arrange(g43, g_legend(g42), g41, g42 + theme(legend.position="none"),
            ncol=2, widths=c(4, 2), heights=c(2, 4))
