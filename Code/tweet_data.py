import json
from datetime import datetime, date

with open('players.json') as f:
	players = json.load(f)

# Remove the empty lists
players = [player for player in players if player]
players_name = [player[0]['user']['name'] for player in players]

# Player information: screen_name, created time, number of tweets, number of follower,
# number of friends, number of favorites
players_info = list()
for player in players:
	user = player[0]['user']
	players_info.append([user['screen_name'],
						 datetime.strptime(user['created_at'][0:19] + user['created_at'][-5::1],
						 	"%a %b %d %H:%M:%S %Y").date(),
						 len(player),
						 user['followers_count'],
						 user['friends_count'],
						 user['favourites_count']])

# Output csv file
with open('tweet_data.csv', 'w') as outfile:
	csv_out = csv.writer(outfile)
	csv_out.writerow(['screen_name', 'created_time', 'tweet_num', 'followers', 'friends', 'favorites'])
	for info in players_info:
		csv_out.writerow(info)