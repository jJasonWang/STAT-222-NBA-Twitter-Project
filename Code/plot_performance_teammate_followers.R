data <- read.csv("Data/team.csv", stringsAsFactors=FALSE)

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




