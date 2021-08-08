#################################
####    LOAD DEPENDENCIES    ####
#################################

if (!require('rvest')) install.packages('rvest')
library('rvest')

##########################
####    PARAMETERS    ####
##########################

base_url_start = 'https://en.wikipedia.org/wiki/'
FA_base_url_end = '_FA_Premier_League'
Prem_base_url_end = '_Premier_League'

# years that line up with our transfer data
years = c('1992–93','1993–94','1994–95','1995–96','1996–97','1997–98','1998–99','1999–2000',
          '2000–01','2001–02','2002–03','2003–04','2004–05','2005–06','2006–07','2007–08','2008–09','2009–10',
          '2010–11','2011–12','2012–13','2013–14','2014–15','2015–16','2016–17','2017–18','2018–19')

# for getting the right xpath (most results tables are the 5th table, for these years, they're the 6th)
sixth_tables <- c('1998–99','1999–2000', '2000–01','2001–02', '2003–04', '2005–06','2012–13','2016–17')

prem_years <- c('2013–14','2014–15','2015–16','2016–17','2017–18','2018–19')

# xpath of the final league results table
xp = '//*[@id="mw-content-text"]/div/table'

#########################
####    EXECUTION    ####
#########################

scrape_results <- function() {
    
    for (year in years) {
        
        print(sprintf('Getting data for the year %s', year))
        
        # compose url for this year and read in the html
        # takes into account the change in prem name
        if (year %in% prem_years) {
            full_url = paste(base_url_start, year, Prem_base_url_end, sep='')
        } else {
            full_url = paste(base_url_start, year, FA_base_url_end, sep='')
        }
        
        # grab html
        data <- read_html(full_url)
        
        # xpath is different for certain years ¯\_(ツ)_/¯
        if (year %in% sixth_tables) {
            num='[6]' 
        } else {
            num='[5]'
        }
        
        # full xpath
        full_xpath = paste(xp, num, sep='')
        
        
        # select the final (season's end) league table
        table <- data %>%
            html_node(xpath=full_xpath) %>%
            html_table(fill=TRUE) # some tables had weird formatting
        
        # add current year to the dataframe
        table <- cbind(year=years[1], table) #! This is wrong - manually fixing the data
        
        # keep first 20 rows, first 12 columns (some yrs had weird formatting)
        table <- table[1:20, 1:12]
        
        # write table to csv
        outfile = paste(year, '_EPLresults.csv')
        
        write.csv(table, file=outfile, row.names=FALSE)
        
        print(sprintf('Done with %s', year))
        
    }
    
    print('Done scraping')
}


scrape_results()