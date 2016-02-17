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

names(X) <- c("# of Tweets", "Followers", "Friends",
              "Game", "Game Started", "Minute Played",
              "3-Point Made", "3-Point Attempts",
              "2-Point Made", "2-Point Attempts",
              "Free Throw Made", "Free Throw Attempts",
              "Offensive Rebound", "Defensive Rebound",
              "Assists", "Steals", "Blocks",
              "Turnovers", "Fouls", "Points")

look_up <- c("Tweets", "Follow", "Friends",
             "G", "GS", "MP",
             "3PM", "3PA", "2PM", "2PA", "FTM", "FTA",
             "ORB", "DRB", "AST", "STL", "BLK",
             "TOV", "F", "PTS")
names(look_up) <- names(X)
match_label <- function(x){
  look_up[x]
}

# Correlation matrix
cor_mat <- cor(X)
# Change it into a long format data.frame
cor_df <- melt(cor_mat)

# Adjust the order of factor for better visualization
cor_df$Var1 <- factor(as.character(cor_df$Var1), levels=rev(names(X)))

##########Figure1: Correlation matrix##########
g1 <- ggplot(cor_df, aes(x=Var1, y=Var2, fill=value)) +
  geom_tile() + coord_flip() +
  scale_fill_distiller("Correlation", palette="RdBu", limits=c(-1, 1)) + 
  scale_y_discrete(labels=match_label) +
  labs(title="Tweet and Performance Correlation Matrix", x="", y="") +
  theme(plot.title=element_text(size=25, face="bold"),
        axis.text.x=element_text(size=12, angle=30, vjust=0.8),
        axis.text.y=element_text(size=14),
        legend.text=element_text(size=12),
        legend.title=element_text(size=14))
# axis.text.x=element_blank(), axis.ticks.x=element_blank()
g1




#----------Second----------
#Divided turnover into 3 categories.
tweet_NBA$TOV2 <- cut(tweet_NBA$TOV, c(0, 50, 100, Inf),
                      include.lowest=TRUE)

##########Figure2: Points, turnovers, follower##########
g2 <- ggplot(tweet_NBA, aes(x=PTS, y=log(followers), color=TOV2)) +
  geom_point(size=2) +
  geom_smooth(data=tweet_NBA, aes(x=PTS, y=log(followers), group=1)) +
  scale_color_discrete("Turnover",
                       breaks= c("[0,50]", "(50,100]", "(100,Inf]"),
                       labels=c("< 50", "50 ~ 100", "> 100")) + 
  labs(title="Players' Number of Followers (log scale) vs. Points\nColor-Coded by Turnovers",
       x="Points", y="Followers (log scale)") +
  theme(axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=13),
        axis.title.x=element_text(size=18),
        axis.title.y=element_text(size=18),
        plot.title=element_text(size=25, face="bold"),
        legend.title=element_text(size=14),
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
               vjust=-0.5, size=5)


#----------Fourth----------
# Read the data with number of follower in team
follower <- read.csv("Data/player_follow.csv", stringsAsFactors=FALSE)

# Merge two dataset
tweet_follow <- merge(follower, tweet_NBA, all.x=TRUE)

# Divided into three categories
tweet_follow$followers_team <- cut(tweet_follow$followers_in_team,
                                   c(0, 3, 7, Inf), include.lowest=TRUE)

change_format <- function(l) {
  # turn in to character string in scientific notation
  l <- format(l, scientific = TRUE)
  l <- sapply(l, function(x) strsplit(x, "e")[[1]][1])
  # return this as an expression
  parse(text=l)
}

##########Figure4: Number of teammate following, assit, minute played##########
g41 <- ggplot(tweet_follow[tweet_follow$AST !=0, ], aes(x=log(AST), y=MP, color=followers_team)) +
  geom_point(size=2) +
  labs(x="Assists (log scale)", y="Minutes Played") +
  theme(legend.position="none",
        axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=13),
        axis.title.x=element_text(size=18),
        axis.title.y=element_text(size=18))
  

g42 <- ggplot(tweet_follow, aes(x=MP, fill=followers_team, color=followers_team)) +
  geom_density(alpha=0.5) +
  scale_fill_discrete("# of\nfollower\nin team",
                      breaks=c("[0,3]", "(3,7]", "(7,Inf]"),
                      labels=c("< 3", "3 ~ 7", "> 7")) + 
  coord_flip() + labs(x="", y=expression(paste("Density (", 10^-4, ")"))) +
  scale_color_discrete(guide=FALSE) + 
  theme(axis.text.x=element_text(size=10),
        axis.text.y=element_text(size=10),
        axis.title.x=element_text(size=13),
        legend.title=element_text(size=17),
        legend.text=element_text(size=12))

g43 <- ggplot(tweet_follow, aes(x=log(AST), fill=followers_team, color=followers_team)) +
  geom_density(alpha=0.5) + labs(x="", y="Density") + 
  theme(legend.position="none",
        axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=15),
        axis.title.y=element_text(size=20))

# Function return the legend of a ggplot object
g_legend <- function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}
grid.arrange(g43, g_legend(g42), g41 + geom_jitter(width=0.2, height=0.1, size=2),
             g42 + scale_y_continuous(labels=change_format) + theme(legend.position="none"),
            ncol=2, widths=c(4, 2), heights=c(2, 4),
            top=textGrob("In-team Followers vs. Assist and Minutes Played",
                           gp=gpar(fontsize=25)))
g <- arrangeGrob(g43, g_legend(g42), g41 + geom_jitter(width=0.2, height=0.1, size=2),
                 g42 + scale_y_continuous(labels=change_format) + theme(legend.position="none"),
                 ncol=2, widths=c(4, 2), heights=c(2, 4),
                 top=textGrob("In-team Followers vs. Assist and Minutes Played",
                              gp=gpar(fontsize=25)))

