import csv
import json
import twitter
from time import sleep
from datetime import datetime, date, time

#API
CONSUMER_KEY       = ""
CONSUMER_SECRET    = ""
OAUTH_TOKEN        = ""
OAUTH_TOKEN_SECRET = ""

auth = twitter.oauth.OAuth(OAUTH_TOKEN, OAUTH_TOKEN_SECRET,
                           CONSUMER_KEY, CONSUMER_SECRET)

api = twitter.Twitter(auth=auth)

# Read the csv file and get the players' tweet screen names
tweet_account = list()
filename = ''
with open(filname, 'r') as f:
	reader = csv.reader(f) 
	for row in reader:
		tweet_account.append(row)

screen_names = [account[1] for account in tweet_account]

# Function that retrieve players data
# Modified from Jarrod's code

# If the team player screen name is None, the function will output an empty list
# If it searches the player tweet and gets nothing, it will also output an empty list
# If it give you an empty list message, try to search the 
# palyer account again(they may change the account)

def retrieve_timeline(screen_name):
	print("-"*10 + "Beginning of retrieval of " + screen_name + "-"*10)

	# If the player don't have twitter account, skip it
	if screen_name == "None": 
		print("Jump to next screen_name")
		timeline = []
		return(timeline)

	# Retrieve timeline
	try:
		timeline = api.statuses.user_timeline(screen_name=screen_name,
											  count=50, include_rts=1)

		# Empty list
		if not timeline:
			print("Empty list: cannot find any tweets for the screen name: " + screen_name)
			print("Try to search the name on Twitter again or replace the player account by None from the list.")
			return(timeline)

	except:
		try:
			# Try whether it hits the limit or just cannot fint the user
			timeline = api.statuses.user_timeline(screen_name='NBA', count=1,
												  include_rts=1)

			print("Cannot find the account for the screen name: " + screen_name)
			print("Try to search the name on Twitter again or replace the player account by None from the list.")
			
			timeline = []
			return(timeline)
		except:	
			print("-"*10 + "Reached rate limit; sleeping 15 minutes" + "-"*10)
			sleep(900)
			timeline = api.statuses.user_timeline(screen_name=screen_name,
											  	  count=50)

	times = [t['created_at'][0:19] + t['created_at'][-5::1] for t in timeline]
	dates = [datetime.strptime(t, "%a %b %d %H:%M:%S %Y").date() for t in times]
	dates_bool = [d > date(2015, 10, 26) for d in dates]

	# If the oldest time is after 10/26, then we keep querying the screen name
	if dates_bool[-1]:
		max_id = timeline[-1]['id'] 
		while dates_bool[-1]:
			try:
				next_timeline = api.statuses.user_timeline(screen_name=screen_name,
														   max_id = max_id - 1,
														   count=50,
														   include_rts=1)
			except:
				print("-"*10 + "Reached rate limit; sleeping 15 minutes" + "-"*10)
				sleep(900)
				next_timeline = api.statuses.user_timeline(screen_name=screen_name,
														   max_id = max_id - 1,
														   count=50,
														   include_rts=1)

			times = [t['created_at'][0:19] + t['created_at'][-5::1] for t in next_timeline]
			dates = [datetime.strptime(t, "%a %b %d %H:%M:%S %Y").date() for t in times]
			dates_bool = [d > date(2015, 10, 26) for d in dates]

			if not next_timeline:
				break
			if dates_bool[-1]:
				timeline += next_timeline
			else:
				timeline += next_timeline[0:sum(dates_bool)]

			max_id = next_timeline[-1]['id']

		return(timeline)
	# Remove all the tweets before 10/26
	else:
		return(timeline[0:sum(dates_bool)])


timelines = [retrieve_timeline(screen_name) for screen_name in screen_names]
with open("player3.json", "w") as f:
    json.dump(timelines, f, indent=4, sort_keys=True)

# Check whether all the date is after 10/26
[t[-1]['created_at'] for t in timelines if t]
