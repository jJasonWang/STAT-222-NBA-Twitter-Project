NBA <- read.csv("Data/NBA_2016.csv", stringsAsFactors=FALSE)
NBA_tweet <- read.csv("Data/NBA_player_tweet_account.csv",
                      stringsAsFactors=FALSE)

#Date from http://www.basketball-reference.com/friv/twitter.cgi

#Players
NBA_player <- NBA$Player
#Remove those duplicate rows due to team switching


#Merge two data
tweet_account <- merge(NBA, NBA_tweet, all.x=TRUE, by.x="Player", by.y="Player")

#Retrieve player, account, team
tweet_account <- tweet_account[c('Player', 'Twitter', 'Tm')]

#Remove @
tweet_account$Twitter <- gsub("@", "", tweet_account$Twitter)

#Order by team
tweet_account <- tweet_account[order(tweet_account$Tm), ]

#Assign people to each team
team <- unique(tweet_account$Tm)
person <- rep(c("Jamie", "Jason", "Mengfei"), length.out=length(team))

tweet_account$person <- person[tweet_account$Tm]

#write out csv file
write.csv(tweet_account, "tweet_account.csv")

