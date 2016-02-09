# all the data files are in Data folder
with open("tweet_account_final.csv") as f:
    player_n_sn_t = f.readlines()

with open("teams.txt") as f:
    teams = f.readlines()

with open("players_following.json") as f:
    players_following_dict = json.load(f)

teams = [team.strip() for team in teams]

################### The overall network analysis #######################################
def get_followings(ids):
	player_following = [api.friends.ids(user_id = id, count = 5000) for id in ids]
	player_following_ids = [m['ids'] for m in player_following]
	return(player_following_ids)


def get_relationship(player_ids, player_following_ids):
	following_mat = [[player_id in player_following_id for player_following_id in player_following_ids] for player_id in player_ids]
	return(following_mat)


player_n_sn_t = [item.strip().split(',') for item in player_n_sn_t[1:]]
players_dict = {} # dictionary with key=screen_name, value=[player name, team, id, followings]
num_players_tweeted = len(players_following_dict)
for i in range(num_players_tweeted):
    sn = players_following_dict[i]['screen_name']
    id = players_following_dict[i]['id']
    following_id = players_following_dict[i]['following_id']
    name, team = [(player[0], player[2]) for player in player_n_sn_t if player[1] == sn][0]
    players_dict[sn] = [name, team, id, following_id]

all_ids = [player[2] for player in list(players_dict.values())]
all_followingids = [player[3] for player in list(players_dict.values())]
all_mat = get_relationship(all_ids, all_followingids)
all_mat = np.matrix(all_mat)
all_names = [player[0] for player in list(players_dict.values())]

# the networkx code for plotting the graph is in the plot_network.ipynb

########################################################################################
################### The team network analysis #######################################
from matplotlib import pyplot as plt
import numpy as np

# split into 30 teams
teams_players_dict = {}
for i in range(30):
    team = teams[i]
    teams_players_dict[team] = [player[:] for player in list(players_dict.values()) if player[1] == team]

# matrix of each team relationship: row is the user, column is whether the user is following that specific account or not
team_followingmats = {}
for team in teams_players_dict.keys():
    team_ids = [player[2] for player in teams_players_dict[team]]
    team_followingids = [player[3] for player in teams_players_dict[team]]
    labels = [player[0] for player in teams_players_dict[team]]
    mat =  get_relationship(team_ids, team_followingids)
    team_followingmats[team] = {"mat": mat, "names": labels}

# plot matrix for GSW
fig, ax = plt.subplots()
plt.subplots_adjust(left=0.1, right=1.0, bottom=0.4, top=0.9)
team_mat = np.matrix(team_followingmats['GSW']['mat'])
team_names = team_followingmats['GSW']['names']
mat = ax.imshow(team_mat, cmap='Greys', interpolation='nearest')
ax.set_xticklabels([])
ax.set_yticklabels([])
ax.set_xticks([])
ax.set_yticks([])
plt.xlabel('Team players')
plt.ylabel('Followed by')
plt.show()

# plot matrix for PHI
fig, ax = plt.subplots()
plt.subplots_adjust(left=0.1, right=1.0, bottom=0.4, top=0.9)
team_mat = np.matrix(team_followingmats['PHI']['mat'])
team_names = team_followingmats['PHI']['names']
mat = ax.imshow(team_mat, cmap='Greys', interpolation='nearest')
ax.set_xticklabels([])
ax.set_yticklabels([])
ax.set_xticks([])
ax.set_yticks([])
plt.xlabel('Team players')
plt.ylabel('Followed by')
plt.show()

# Get average number of teammate followers for each team
def count_peers_followed(player_id, peer_following_ids):
    count = sum([player_id in peer_following_id for peer_following_id in peer_following_ids])
    return(count)


def get_team_pfm_chrts(teams_players_dict, team_pfm):
    team_pfm_chrts = []
    for team in teams_players_dict.keys():
        peer_following_ids = [player[3] for player in teams_players_dict[team]]
        num_followed_by_peers = [count_peers_followed(player[2], peer_following_ids) for player in teams_players_dict[team]]
        avg_followed_by_peers = sum(num_followed_by_peers) / len(num_followed_by_peers)
        num_following = [len(player[3]) for player in teams_players_dict[team]]
        avg_following = sum(num_following) / len(num_following)
        winodds = float([pfm[-5] for pfm in team_pfm if pfm[-2] == team][0])
        team_pfm_chrts.append([team, winodds, avg_followed_by_peers, avg_following])
    return(team_pfm_chrts)


# get the performance and following characteristics for each team
# the file is under Data folder
with open("team_standings2.csv") as f:
    team_standings = f.readlines()

team_ranks = [team.strip().split('\t')[:]for team in team_standings[1:]]
team_pfm_chrts = get_team_pfm_chrts(teams_players_dict, team_ranks)


def get_conference(team_abrev, team_conference):
    conf = [team[1] for team in team_conference if team[0] == team_abrev][0]
    return(conf)

# get the conference for each team
team_conference = [team[-2:]for team in team_ranks]

# Next, plot the side-by-side bar chart of average number of teammate followers
# for each team grouped by conference
# side-by-side bar charts
team_pfm_chrts_by_avg_peers =  sorted(team_pfm_chrts, key=itemgetter(2), reverse=True)
xvals_E = [team[2] for team in team_pfm_chrts_by_avg_peers if get_conference(team[0],team_conference) == 'E']
yvals_E = [team[0] for team in team_pfm_chrts_by_avg_peers if get_conference(team[0],team_conference) == 'E']
xvals_W = [team[2] for team in team_pfm_chrts_by_avg_peers if get_conference(team[0],team_conference) == 'W']
yvals_W = [team[0] for team in team_pfm_chrts_by_avg_peers if get_conference(team[0],team_conference) == 'W']
# Eastern
plt.style.use("ggplot")
fig, ax = plt.subplots()
plt.barh(bottom=range(15,0,-1), width = xvals_E, height = 0.7, align='center', color = '#006BB6')
plt.yticks(np.arange(15,0,-1), yvals_E)
plt.xticks(range(0,13))
plt.grid(axis='x',          # set y-axis grid lines
        linestyle='--',     # use dashed lines
        which='major',      # only major ticks
        color='lightgrey',  # line colour
        alpha=0.7)
plt.title('Eastern Conference')
plt.xlabel('Average number of in-team followers')
plt.show()


# Western
fig, ax = plt.subplots()
plt.barh(bottom=range(15,0,-1), width = [-i for i in xvals_W], height = 0.7, align='center', color = '#CF0032')
ax.yaxis.set_ticks_position('right')
plt.yticks(np.arange(15,0,-1), yvals_W)
plt.xticks(range(-12,1),range(12,-1,-1))
plt.grid(axis='x',          # set y-axis grid lines
        linestyle='--',     # use dashed lines
        which='major',      # only major ticks
        color='lightgrey',  # line colour
        alpha=0.7)
plt.title('Western Conference')
plt.xlabel('Average number of in-team followers')
plt.show()


# Finally, performance v.s. avg num of in-team followers grouped by conference
# Data is in Data/team_pfm_chrts.csv
# Code is in plot_performance_tmfollowers.R





