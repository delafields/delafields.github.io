import pandas as pd
import re
from helpers import get_soup, color_urls
import webcolors
import wolframalpha
from secret import app_id

def extract_colors(url, league):

    # grab the html, find the team buttons
    soup = get_soup(url)
    teams = soup.find_all("a", {"class", "team-button"})

    for t in teams:
        Team = t.text

        style = str(t["style"])

        # get the primary color (stored in the background-color of the style attr)
        primary_reg = re.compile("#(?:[0-9a-fA-F]{3}){1,2}")
        primary = primary_reg.findall(style)[0]

        # get the secondary color (stored in the border-bottom of the style attr)
        secondary_reg = re.compile("border-bottom: 4px solid .{7}")
        secondary_temp = secondary_reg.findall(style)
        # black isn't given a hex, it's given 'black'
        if not secondary_temp:
            secondary = "#000000"
        else:
            secondary = secondary_temp[0][-7:]

        # edge cases
        if primary == "#024":  primary = "#002244"
        elif primary == "#000": primary = "#000000"
        elif primary == "#111": primary = "#111111"
        
        if secondary == "#fff": secondary = "#ffffff"
        elif secondary == "#000; c": secondary = "#000000"
        elif secondary == " #FC4C0": secondary = "#FC4C00"
        elif secondary == "#fff; c": secondary = "#ffffff"
        elif secondary == "black; ": secondary = "#000000"

        team_colors.loc[len(team_colors)] = [Team, primary, secondary, league]

team_colors = pd.DataFrame(columns = ["Team", "hex_Primary_Color", "hex_Secondary_Color", "League"])

# loop through each league, grab the html and extract the colors
for league in color_urls:

    url = color_urls[league][0]
    league_name = color_urls[league][1]

    print(f"Workin on the {league_name}")

    extract_colors(url, league_name)

# Edge Cases
# Manually add championship winning teams
team_colors.loc[len(team_colors)] = ["Blackburn Rovers", "#00002d", "#78bcff", "EPL"]
team_colors.loc[len(team_colors)] = ["Sheffield United", "#EE2737", "#0D171A", "EPL"]
team_colors.loc[len(team_colors)] = ["Ipswich Town", "#0e00f7", "#FFFFFF", "EPL"]
team_colors.loc[len(team_colors)] = ["Nottingham Forest", "#E53233", "#FFFFFF", "EPL"]
team_colors.loc[len(team_colors)] = ["Sevilla", "#cb282b", "#a47433", "La Liga"]
team_colors.loc[len(team_colors)] = ["Baltimore Bullets (original) (folded in 1954)", "#002B5C", "#E31837", "NBA"]
team_colors.loc[len(team_colors)] = ["Genoa", "#ED2D22", "#202A4E", "Serie A"]
team_colors.loc[len(team_colors)] = ["Torino", "#881f19", "#FFFFFF", "Serie A"]
team_colors.loc[len(team_colors)] = ["Pro Vercelli", "#E31F2B", "#FFFFFF", "Serie A"]
team_colors.loc[len(team_colors)] = ["Sampdoria", "#2737a3", "#000000", "Serie A"]
team_colors.loc[len(team_colors)] = ["Hellas Verona", "#172983", "#FFED00", "Serie A"]
team_colors.loc[len(team_colors)] = ["Novese", "#0099CC", "#FFFFFF", "Serie A"]
team_colors.loc[len(team_colors)] = ["Casale", "#000000", "#FFFFFF", "Serie A"]
team_colors.loc[len(team_colors)] = ["Sunderland", "#ff0000", "#FFFFFF", "EPL"]
team_colors.loc[len(team_colors)] = ["Sheffield Wednesday", "#0e00f7", "#000015", "EPL"]
team_colors.loc[len(team_colors)] = ["Preston North End", "#040040", "#FFDF00", "EPL"]
team_colors.loc[len(team_colors)] = ["Derby County", "#000000", "#FFFFFF", "EPL"]
team_colors.loc[len(team_colors)] = ["Portsmouth", "#001489", "#FFFFFF", "EPL"]
team_colors.loc[len(team_colors)] = ["Athletic Bilbao", "#EE2523", "#FFFFFF", "La Liga"]
team_colors.loc[len(team_colors)] = ["Real Sociedad", "#0062B8", "#FFFFFF", "La Liga"]
team_colors.loc[len(team_colors)] = ["Lazio", "#7FD3F4", "#FFFFFF", "Serie A"]

  

# https://stackoverflow.com/questions/9694165/convert-rgb-color-to-english-color-name-like-green-with-python
def get_css3_color_name(hex_code):

    # convert hex to an rgb triplet
    hex_code = hex_code[1: ]
    red, green, blue = bytes.fromhex(hex_code)
    rgb_triplet = (red, green, blue)

    min_colors = {}
    for key, name in webcolors.css3_hex_to_names.items():
        r_c, g_c, b_c = webcolors.hex_to_rgb(key)
        rd = (r_c - rgb_triplet[0]) ** 2
        gd = (g_c - rgb_triplet[1]) ** 2
        bd = (b_c - rgb_triplet[2]) ** 2
        min_colors[(rd + gd + bd)] = name
    return min_colors[min(min_colors.keys())].capitalize()

def get_css2_color_name(hex_code):

    # convert hex to an rgb triplet
    hex_code = hex_code[1: ]
    red, green, blue = bytes.fromhex(hex_code)
    rgb_triplet = (red, green, blue)

    min_colors = {}
    for key, name in webcolors.css21_hex_to_names.items():
        r_c, g_c, b_c = webcolors.hex_to_rgb(key)
        rd = (r_c - rgb_triplet[0]) ** 2
        gd = (g_c - rgb_triplet[1]) ** 2
        bd = (b_c - rgb_triplet[2]) ** 2
        min_colors[(rd + gd + bd)] = name
    return min_colors[min(min_colors.keys())].capitalize()

# get the color name for each hex code from the `webcolors` package
team_colors["wc_css2_Primary_Name"] = team_colors["hex_Primary_Color"].apply(lambda c: get_css2_color_name(c))
team_colors["wc_css2_Secondary_Name"] = team_colors["hex_Secondary_Color"].apply(lambda c: get_css2_color_name(c))
team_colors["wc_css3_Primary_Name"] = team_colors["hex_Primary_Color"].apply(lambda c: get_css3_color_name(c))
team_colors["wc_css3_Secondary_Name"] = team_colors["hex_Secondary_Color"].apply(lambda c: get_css3_color_name(c))

# finds the nth occurence of a character
# https://stackoverflow.com/questions/1883980/find-the-nth-occurrence-of-substring-in-a-string
def find_nth(haystack, needle, n):
    start = haystack.find(needle)
    while start >= 0 and n > 1:
        start = haystack.find(needle, start+len(needle))
        n -= 1
    return start


client = wolframalpha.Client(app_id)
# use the wolfram alpha api to get color names from hex codes
def get_wolfram_colors(color):
    print(f'Hitting wolfram for {color}')
    res = client.query(color)

    for pod in res.pods:
        if pod['@title'] == 'Nearest named HTML colors':

            colors = pod['subpod']['plaintext']
            
            # get the first english color name provided
            start_color_one = find_nth(colors, '|', 6)
            end_color_one = find_nth(colors, '|', 7)
            color_one = colors[start_color_one+1 : end_color_one].strip().capitalize()

            # get the second english color name provided
            start_color_two = find_nth(colors, '|', 11)
            end_color_two = find_nth(colors, '|', 12)
            color_two = colors[start_color_two+1 : end_color_two].strip().capitalize()

            # join the two color names together - split later
            wa_colors = f"{color_one},{color_two}"

            print(f"color 1: {color_one}, color 2: {color_two}")
            return wa_colors

# get color names from wolfram alpha
print("Starting wolfram primary colors")
team_colors["wa_Primary_Names"] = team_colors["hex_Primary_Color"].apply(lambda c: get_wolfram_colors(c))
print("Starting wolfram secondary colors")
team_colors["wa_Secondary_Names"] = team_colors["hex_Secondary_Color"].apply(lambda c: get_wolfram_colors(c))


# create a temporary df of primary and secondary color names
new_wa_primary   = team_colors["wa_Primary_Names"].str.split(",", n = 1, expand = True)
new_wa_secondary = team_colors["wa_Secondary_Names"].str.split(",", n = 1, expand = True)

# add a col for each primary color name supplied by wolfram alpha
team_colors["wa_Primary_Name_1"] = new_wa_primary[0]
team_colors["wa_Primary_Name_2"] = new_wa_primary[1]

# add a col for each secondary color name supplied by wolfram alpha
team_colors["wa_Secondary_Name_1"] = new_wa_secondary[0] 
team_colors["wa_Secondary_Name_2"] = new_wa_secondary[1] 

team_colors.to_csv("data/team_colors.csv", index = False)

print("Done!")