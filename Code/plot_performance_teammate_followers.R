data <- read.csv("Data/team_pfm_chrts.csv", stringsAsFactors=FALSE)

g1 <- ggplot(data, aes(x=avg_followed, y=winodds)) 

g1 + geom_text(data=data, aes(x=avg_followed, y=winodds,
                         label=team, color=conference), size=5) +
  geom_smooth(aes(group=1), method="lm", color='#666666', se=FALSE) +
  scale_color_discrete("Conference", labels=c("East", "West")) +
  labs(title="Performance v.s. Coherence", x="Average In-Team Followers",
       y="Winning Percentage") +
  theme(axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=15),
        axis.title.x=element_text(size=15),
        axis.title.y=element_text(size=20),
        plot.title=element_text(size=25, face="bold"),
        legend.title=element_text(size=17),
        legend.text=element_text(size=12))

# Create an data for legend
df2 <- data.frame(x=c(0, 0), y=c(0, 0), colors=c("E", "W"))

# Type 1
g1 <- ggplot(df2, aes(x=x, y=y, color=colors)) + geom_point(size=5) +
  xlim(range(data$avg_followed)[1], range(data$avg_followed)[2]) +
  ylim(range(data$winodds)[1], range(data$winodds)[2]) +
  geom_text(data=data, aes(x=avg_followed, y=winodds,
                           label=team, color=conference),
            show.legend=FALSE) +
  geom_smooth(data=data, aes(x=avg_followed, y=winodds, group=1),
              method="lm", color='#666666', se=FALSE) +
  scale_color_discrete("Conference", labels=c("East", "West")) +
  labs(title="Performance v.s. Coherence", x="Average In-Team Followers",
       y="Winning Percentage") +
  theme(axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=15),
        axis.title.x=element_text(size=15),
        axis.title.y=element_text(size=20),
        plot.title=element_text(size=25, face="bold"),
        legend.title=element_text(size=17),
        legend.text=element_text(size=12))



#Type 2
g2 <- ggplot(df2, aes(x=x, y=y, fill=colors)) + geom_tile() +
  xlim(range(data$avg_followed)[1], range(data$avg_followed)[2]) +
  ylim(range(data$winodds)[1], range(data$winodds)[2]) +
  geom_text(data=data, aes(x=avg_followed, y=winodds,
                           label=team, color=conference, fill=NA),
            show.legend=FALSE) +
  geom_smooth(data=data, aes(x=avg_followed, y=winodds, group=1, fill=NA),
              method="lm", color='#666666', se=FALSE, show.legend=FALSE) +
  scale_fill_discrete("Conference", labels=c("East", "West")) +
  labs(title="Performance v.s. Coherence", x="Average In-Team Followers",
       y="Winning Percentage") +
  theme(axis.text.x=element_text(size=13),
        axis.text.y=element_text(size=15),
        axis.title.x=element_text(size=15),
        axis.title.y=element_text(size=20),
        plot.title=element_text(size=25, face="bold"),
        legend.title=element_text(size=17),
        legend.text=element_text(size=12))