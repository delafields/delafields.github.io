import pandas as pd
import re
from helpers import get_soup, championship_urls

def get_champs_table(league):
        print(f"Workin on {league}")

        url = championship_urls[league][0]
        selector = championship_urls[league][1]

        soup = get_soup(url)

        if league == "La Liga":
                champ_table = soup.find_all("table", {"class": selector})[-1]
        else:
                champ_table = soup.select_one(selector)
                
                
        champ_df = pd.read_html(str(champ_table))[0]
        champ_df["League"] = league

        league = league.replace(" ", "")

        return champ_df

for league in championship_urls:
        if league == "Serie A":
                champ_df = get_champs_table(league = league)[["Club", "Champions", "League"]]
                champ_df = champ_df.rename(columns = {"Club": "Team", "Champions": "Wins"})
                # don't have many here
                champ_df = champ_df.replace({"Milan": "A.C. Milan", 
                                             "Internazionale": "Inter Milan", 
                                             "Roma": "A.S. Roma"})

                league = league.replace(" ", "")
                champ_df.to_csv(f"data/champs/{league}_Champions.csv", index = False)

        elif league == "La Liga":
                champ_df = get_champs_table(league = league)[["Club", "Winners", "League"]]
                champ_df = champ_df.rename(columns = {"Club": "Team", "Winners": "Wins"})
                champ_df = champ_df.replace({"Real Madrid": "Real Madrid CF", 
                                             "Barcelona": "Barcelona FC", 
                                             "Atlético Madrid": "Atletico Madrid",
                                             "Valencia": "Valencia CF", 
                                             "Deportivo La Coruña": "Deportivo"})

                league = league.replace(" ", "")
                champ_df.to_csv(f"data/champs/{league}_Champions.csv", index = False)

        elif league == "EPL":
                champ_df = get_champs_table(league = league)[["Club", "Winners", "League"]]
                champ_df = champ_df.rename(columns = {"Club": "Team", "Winners": "Wins"})
                champ_df = champ_df.replace({"Newcastle United": "Newcastle United FC", 
                                             "Wolverhampton Wanderers": "Wolverhampton", 
                                             "Watford": "Watford FC",
                                             "Southampton": "Southampton FC"})

                champ_df.to_csv(f"data/champs/{league}_Champions.csv", index = False)

        elif league == "NHL":
                champ_df = get_champs_table(league = league)[["Team", "Wins", "League"]]
                champ_df["Team"] = champ_df["Team"].str.replace(r"\[.\]", "")

                champ_df.to_csv(f"data/champs/{league}_Champions.csv", index = False)

        elif league == "MLB":
                champ_df = get_champs_table(league = league)[["Team", "Wins", "League"]]
                champ_df = champ_df.replace({"New York/San Francisco GiantsNY until 1957, SF 1958-present": "San Francisco Giants",
                                             "Brooklyn/Los Angeles DodgersBKN until 1957, LA 1958-present": "Los Angeles Dodgers",
                                             "Philadelphia/Kansas City/Oakland AthleticsPHI until 1954, KC 1955-1967, OAK 1968-present": "Oakland Athletics",
                                             "Boston/Milwaukee/Atlanta BravesBOS until 1952, MIL 1953-1965, ATL 1966-present": "Atlanta Braves",
                                             "St. Louis Browns/Baltimore OriolesSTL until 1953, BAL 1954-present": "Baltimore Orioles",
                                             "Washington Senators/Minnesota TwinsWSH until 1960, MIN 1961-present": "Minnesota Twins",
                                             "Washington Senators/Texas Rangers WSH until 1971, TEX 1972-present": "Texas Rangers",
                                             "Montreal Expos/Washington Nationals MTL until 2004, WSH 2005-present": "Washington Nationals",
                                             "Seattle Pilots/Milwaukee Brewers SEA 1969, MIL 1970-present": "Milwaukee Brewers"})

                champ_df.to_csv(f"data/champs/{league}_Champions.csv", index = False)

        elif league == "NBA":
                champ_df = get_champs_table(league = league)[["Teams", "Win", "League"]]
                champ_df = champ_df.rename(columns = {"Teams": "Team", "Win": "Wins"})
                champ_df["Team"] = champ_df["Team"].str.replace(r"\[.*\]", "")
                champ_df["Wins"] = champ_df["Wins"].replace("—", 0)

                champ_df.to_csv(f"data/champs/{league}_Champions.csv", index = False)

        elif league == "NFL":
                champ_df = get_champs_table(league = league)[["Team", "Wins", "League"]]
                champ_df = champ_df[: -1] # remove last header row
                champ_df["Team"] = champ_df["Team"].str.replace(r"\[.*\]", "") # get rid of bracketed numbers
                champ_df["Team"] = champ_df["Team"].str.rstrip(r"(N|n|A|a)")   # get rid of text artifacts
                champ_df = champ_df.replace({"Boston/New England Patriots": "New England Patriots",
                                             "Oakland/Los Angeles Raiders": "Oakland Raiders",
                                             "Baltimore/Indianapolis Colts": "Indianapolis Colts",
                                             "St. Louis/Los Angeles Rams": "Los Angeles Rams",
                                             "San Diego/Los Angeles Chargers": "Los Angeles Chargers",
                                             "Houston/Tennessee Oilers/Titans": "Tennessee Titans",
                                             "St. Louis/Phoenix/Arizona Cardinals": "Arizona Cardinals"})

                champ_df.to_csv(f"data/champs/{league}_Champions.csv", index = False)

        elif league == "NCAAF":
                champ_df = get_champs_table(league = league)[["Champion", "League"]]
                champ_df = champ_df.rename(columns = {"Champion": "Team"})
                # drop weird multi-champions
                champ_df = champ_df[~champ_df["Team"].str.contains(",")]

                champ_df = champ_df.replace({"LSU": "Louisiana",
                                             "Southern California": "USC",
                                             "Southern California*": "USC",
                                             "Miami (Fla.)": "Miami",
                                             "Florida St.": "Florida State",
                                             "Penn St.": "Penn State",
                                             "Brigham Young": "BYU",
                                             "Ohio St.": "Ohio State",
                                             "Michigan St.": "Michigan State",
                                             "Georgia Tech.": "Georgia Tech",
                                             "Pennsylvania": "Penn"})

                # sum number of wins
                champ_df["Wins"] = champ_df.groupby("Team")["Team"].transform("count")
                champ_df = champ_df.drop_duplicates()

                champ_df.to_csv(f"data/champs/{league}_Champions.csv", index = False)

        elif league == "NCAAB":
                champ_df = get_champs_table(league = league)[["Champion (Record)", "League"]]
                champ_df = champ_df.rename(columns = {"Champion (Record)": "Team"})
                # remove record from team name
                champ_df["Team"] = champ_df["Team"].str.replace(r" \(.*", "")

                # sum number of wins
                champ_df["Wins"] = champ_df.groupby("Team")["Team"].transform("count")
                champ_df = champ_df.drop_duplicates()

                champ_df.to_csv(f"data/champs/{league}_Champions.csv", index = False)
