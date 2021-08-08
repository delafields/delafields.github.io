# NFL Penalties 🏈
Data on NFL penalties from 2009-2018 (as found on [nflpenalties.com](https://www.nflpenalties.com/)).

### Data
There are two separate data files, both excel workbooks, data from 2009-2018 (located in the `data` folder).
1. `by_team_group.xlsx`: penalties per phase of the game (Offense/Defense/Special Teams), per team, per year. Each sheet contains a different year.
    * `Total/Off/Def/ST Ct` - number of penalties
    * `Total/Off/Def/ST Yds` - penalty yardage
    * `Off/Def/ST Presnap` - number of penalties pre-snap
2. `by_penalty.xlsx`: data on 39 specific penalties, per team, per year. Each sheet contains a different penalty. Data for '09-'18 is stacked in each sheet.
    * Each sheet contains
        * `Games` - num games played (includes post season)
        * `Count` - total num penalties committed
        * `Yards Lost` - true yards lost
        * `Dismissed` - num penalties dismissed by opponent
        * `Home` - num penalties home
        * `Away` - num penalties away
        * `Penalty_Outcome` - yardage penalty (see nuances below)
        * `Year`
    * Penalties included
        * `defensive-pass-interference`,`illegal-touch-kick`,`intentional-grounding`,`illegal-use-of-hands`,`fair-catch-interference`,`illegal-blindside-block`,`clipping`,`low-block`,`unnecessary-roughness`,`roughing-the-passer`,`face-mask-15-yards`,`unsportsmanlike-conduct`,`taunting`,`horse-collar-tackle`,`chop-block`,`disqualification`,`roughing-the-kicker`,`offensive-holding`,`illegal-block-above-the-waist`,`offensive-pass-interference`,`tripping`,`illegal-forward-pass`,`illegal-touch-pass`,`defensive-delay-of-game`,`false-start`,`defensive-holding`,`defensive-offside`,`neutral-zone-infraction`,`delay-of-game`,`illegal-formation`,`illegal-shift`,`encroachment`,`illegal-contact`,`ineligible-downfield-pass`,`offside-on-free-kick`,`illegal-motion`,`illegal-substitution`,`ineligible-downfield-kick`,`running-into-the-kicker`
        * *Note - `Penalty_Outcome` for a few penalties were purposely populated with odd values, as follows*
            * Spot fouls (penalty yardage determined by the spot of the foul): 
                * `defensive-pass-interference` &`illegal-touch-kick`. 
                * Given `Penalty_Outcome = 111`
            * Penalties whose yards differ whether they're committed by the defense or the offense OR penalties whose yards depend on the situation: 
                * `intentional-grounding` & `illegal-use-of-hands`. 
                * Given `Penalty_Outcome = 999`