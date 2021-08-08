"""
Comparing Jump Scare Ratings of 2019's horror, thriller and sci-fi titles have
Data Source: https://wheresthejump.com/full-movie-list/

By: Jeremy Fields
Date: 10/15/2019

Inspired by https://github.com/aaronpenne/data_visualization/blob/master/ceo_compensation/dot_pairs_ceo_compensation.py

Dev Notes: Python 3.7
"""

# import packages
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import seaborn as sns
from sklearn.preprocessing import MinMaxScaler
sns.set()

# import data
df = pd.read_csv('./data/500JumpScares.csv')

############################################
# process data
df = df.drop(columns=['Director'], axis=1)

df['Jump_Scare_Rating'] = df['Jump_Scare_Rating'].str.strip() # cleaning up some odd whitespace

df['Jump_Scare_Rating'] = df['Jump_Scare_Rating'].astype('float64')
df['Jump_Count'] = df['Jump_Count'].fillna(0.0).astype(int)

# add jump count to movie name
df['Movie_Name'] = df['Movie_Name'] + ' (' + df['Jump_Count'].astype(str) + ')'

# normalize rating headers via MinMaxScaling
min_max_scaler = MinMaxScaler()
cols_to_normalize = ['Jump_Scare_Rating', 'IMDB_Rating']
df[cols_to_normalize] = min_max_scaler.fit_transform(df[cols_to_normalize])

# scale rating headers up and round them
df['Jump_Scare_Rating'] = df['Jump_Scare_Rating'] * 10
df['IMDB_Rating'] = df['IMDB_Rating'] * 10
df = df.round({'IMDB_Rating': 1, 'Jump_Scare_Rating': 1})

# narrow data to 2019
df_2019 = df[df.Year == 2019]
df_2019

############################################
# Create viz

fig, ax = plt.subplots(figsize=(4, 3), dpi=150)

plt.rcParams['font.family'] = 'monospace'
orange = '#FC8D62'

# FIND DOT POSITIONS AND LABEL ALIGNMENTS
for i in df_2019.index:
    x = [df_2019.loc[i,'Jump_Scare_Rating'], df_2019.loc[i, 'IMDB_Rating']]
    y = [df_2019.loc[i, 'Movie_Name'], df_2019.loc[i, 'Movie_Name']]
    # plot connecting line
    plt.plot(x, y, color='gray',linestyle='--',linewidth=0.5, zorder=-1)
    if x[0] > x[1]:
        plt.text(x[0]+0.2, y[0], df_2019.loc[i, 'Jump_Scare_Rating'], horizontalalignment='left', verticalalignment='center', fontsize=4)
        plt.text(x[1]-0.2, y[1], df_2019.loc[i, 'IMDB_Rating'], horizontalalignment='right', verticalalignment='center', fontsize=4)
    else:
        plt.text(x[0]-0.2, y[0], df_2019.loc[i, 'Jump_Scare_Rating'], horizontalalignment='right', verticalalignment='center', fontsize=4)
        plt.text(x[1]+0.2, y[1], df_2019.loc[i, 'IMDB_Rating'], horizontalalignment='left', verticalalignment='center', fontsize=4)

# PLOT BLACK IMDB DOTS
x = df_2019.loc[:,'IMDB_Rating']
y = df_2019.Movie_Name
sns.scatterplot(x=x, y=y, color='black', legend=False, ax=ax)

# PLOT ORANGE JUMP SCARE RATING DOTS
x = df_2019.loc[:,'Jump_Scare_Rating']
sns.scatterplot(x=x, y=y, color=orange, legend=False, ax=ax)

# AXIS STYLING (REMOVED = ITERATED STYLES)
sns.despine(bottom=True, left=True)
sns.set_style(rc={'figure.facecolor':'white'})
ax.yaxis.set_tick_params(width=0)
ax.get_xaxis().set_visible(False)
ax.tick_params(axis='y', which='major', labelsize=5)
ax.grid(False)

# PLOT Y AXIS LABEL
plt.ylabel(" Movie Name\n(# Jump Scares)", rotation='horizontal', size=5, weight='bold')
ax.yaxis.set_label_coords(-0.15,1.0)

# PLOT LEGEND
colors = [ "black", orange]
texts = [ "IMDB Rating","Jump Scare Rating"]
patches = [ plt.plot([],[], marker="o", ms=3, ls="", color=colors[i], 
            label="{:s}".format(texts[i]) )[0]  for i in range(len(texts)) ]

plt.legend(handles=patches,fontsize=5, bbox_to_anchor=(0.,0.3,1,0),frameon=False,loc='lower left',ncol=1)
 
# PLOT TITLE
plt.suptitle('500 Jump Scares', x=0.51, y=1.05, fontsize=12, family='monospace')
plt.title('2019\'s horror, thriller, and sci-fi titles', x=0.50, y=1.05, fontsize=6)

# ANNOTATE
plt.text(0.,-1.0, 'Note: Jump Scare Rating was normalized and scaled from 0-5 to 0-10', fontsize=4, family='monospace')
plt.text(0.,-1.75, 'Source: wheresthejump.com\n© Jeremy Fields 2019', fontsize=4, family='monospace')

############################################
# Archived Styles

# ax.set_xlabel("Score", size=6)
# plt.xticks([float(x) for x  in range(1,11)])
# sns.set_style("ticks", {"xtick.major.size": 1, "ytick.major.size": 3})
# sns.despine(offset=10, left=True)
# ax.xaxis.set_tick_params(which='both', width=0.5, size=2, color='black', labelcolor='black')

# from matplotlib.ticker import AutoMinorLocator, FormatStrFormatter
# ax.xaxis.set_minor_locator(AutoMinorLocator(4))
# ax.xaxis.set_major_formatter(FormatStrFormatter('%.1f'))

# ax.spines['bottom'].set_linewidth(0.5)
# ax.spines['bottom'].set_color('black')

# PLOT A LEGEND (REMOVED = ITERATED STYLES)
# plot text in whitespace
# plt.text(0.5,4, 'IMDB Rating', color='black', fontsize=4, weight='bold', family='monospace')
# plt.text(0.2,3.5, 'Jump Scare Rating', color='#FC8D62', fontsize=4, weight='bold',family='monospace')

# annotate in center
# plt.text(1.75,-1.0, 'Note: Jump Scare Rating was normalized and scaled from 0-5 to 0-10', fontsize=4, family='monospace')
# plt.text(3.8,-1.75, 'Source: wheresthejump.com\n   © Jeremy Fields 2019', fontsize=4, family='monospace')
# plt.axvline(x=5.0)