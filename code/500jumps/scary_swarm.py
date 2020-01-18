"""
Comparing Jump Scare Ratings and the amount of Jump Scares horror, thriller and sci-fi titles have
Data Source: https://wheresthejump.com/full-movie-list/

By: Jeremy Fields
Date: 10/15/2019

Dev Notes: Python 3.7
"""

# import packages
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import pandas as pd
import seaborn as sns
sns.set()

# import data
df = pd.read_csv('./data/500JumpScares.csv')

############################################
# process data
# remove some weird whitespace
df['Jump_Scare_Rating'] = df['Jump_Scare_Rating'].str.strip()

df['Jump_Scare_Rating'] = pd.to_numeric(df['Jump_Scare_Rating'])

# reorder by Jump Scare Rating
df = df.sort_values(by=['Jump_Scare_Rating'])
df = df.reset_index(drop=True)

############################################
# Create viz

fig, ax = plt.subplots(figsize=(20,10))

colors = ['#FFF9C7','#FEEEA8','#FEDD86','#FEC654','#FEA836','#F78A21','#E96D12','#D15104','#AF3E03','#8A2F04']

# PARAMS
plt.rcParams['font.family'] = 'monospace'
plt.rcParams['legend.title_fontsize'] = 'x-large'
plt.rcParams["axes.labelsize"] = 18
plt.rcParams["xtick.labelsize"] = 16
plt.rcParams["ytick.labelsize"] = 16
sns.set_style({"axes.facecolor": "0.9"})

# PLOT TITLES
plt.suptitle('500 Jump Scares', x=0.51, y=0.98, fontsize=30)
ax.set_title('Quantity over quality. More jump scares equal a higher jump scare rating.\nIMDB seems to disagree. Higher IMDB scores are concentrated in the lower scare ratings.'
             , pad=10)

# MAIN SWARM PLOT
g = sns.swarmplot(x="Jump_Scare_Rating", y="Jump_Count", 
                  hue="IMDB_Rating", palette='YlOrRd',
                  s=10, alpha=.9,
                  data=df, ax=ax)

# PLOT LABELS
plt.xlabel("Jump Scare Rating", labelpad=10)
plt.ylabel("Jump Count", labelpad=10)


# PLOT LEGEND
ax.legend().set_visible(False)

i = 0.5 # for posititioning 
for color in colors:
    ax.add_patch(mpatches.Rectangle((i, 26.5), width=0.2, height=1.5, color=color))
    i += 0.2

plt.text(1.1, 28.5, 'IMDB Rating', size=14)
plt.text(0.2, 27, '1.0', size=12)
plt.text(2.55, 27, '10.0', size=12)

# PLOT AVERAGE JUMP COUNT
avg_jump_count = df["Jump_Count"].mean()
x = plt.gca().axes.get_xlim()
plt.plot(x, len(x) * [avg_jump_count], color="black", linestyle="--", alpha=0.5)
plt.text(0.1, 9.2, 'Avg BOOs', size=14)


# ANNOTATE
plt.text(8.75, 2, 'Source: wheresthejump.com', size=10)
plt.text(8.75, 3, '© Jeremy Fields 2019', size=10)

# ARCHIVED STYLES
# legend across top
# handles, labels = plt.gca().get_legend_handles_labels()
# 
# indexes = [idx for idx, lab in enumerate(labels) if float(lab) % 0.5 == 0]
# new_labels = [float(x) for x in range(1,11)]
# new_handles = [hand for idx, hand in enumerate(handles) if idx in indexes]
# plt.legend(new_handles, new_labels, fontsize='large', bbox_to_anchor=(0,1.05,1,0), frameon=False, loc='upper right', ncol=16, borderaxespad=0.)