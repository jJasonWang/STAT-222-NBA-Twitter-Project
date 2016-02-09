import json
import twitter
from time import sleep


CONSUMER_KEY       = ""
CONSUMER_SECRET    = ""
OAUTH_TOKEN        = ""
OAUTH_TOKEN_SECRET = ""

auth = twitter.oauth.OAuth(OAUTH_TOKEN, OAUTH_TOKEN_SECRET,
                           CONSUMER_KEY, CONSUMER_SECRET)
api = twitter.Twitter(auth=auth)

def retrieve_following(sn_id):
    screen_name = sn_id[0]
    id = sn_id[1]

    print("Beginning retrieval of " + screen_name)

    try:
        player_following = api.friends.ids(user_id = id, count = 5000)
        player_following_ids = player_following['ids']

    except:
        print("Reached rate limit; sleeping 15 minutes")
        sleep(950)
        player_following = api.friends.ids(user_id = id, count = 5000)
        player_following_ids = player_following['ids']

    return({"screen_name": screen_name, "id": id, "following_id": player_following_ids})


# players.json is the file in the project's Google drive folder
with open("players.json") as f:
	players_timelines = json.load(f)

players_sn_ids = [(player_timeline[0]['user']['screen_name'], player_timeline[0]['user']['id']) for player_timeline in players_timelines if player_timeline]
players_following_dict = [retrieve_following(player_sn_id) for player_sn_id in players_sn_ids]

with open("players_following.json", "w") as f:
    json.dump(players_following_dict, f, indent=4, sort_keys=True)