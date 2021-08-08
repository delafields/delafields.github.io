#################################
####    LOAD DEPENDENCIES    ####
#################################

if (!require('rvest')) install.packages('rvest')
library('rvest')
if (!require('openxlsx')) install.packages('openxlsx')
library('openxlsx')

##########################
####    PARAMETERS    ####
##########################

base_url = 'http://www.espn.com/'

url_params = '/attendance/_/year/'

leagues <- c('nba', 'mlb', 'nfl', 'nhl')

years <- seq(2001, 2019)

# full_url = paste(base_url, league, '/attendance/_/year/', year, sep='')

#########################
####    EXECUTION    ####
#########################

# this function scrapes attendance data for a specific sports league
# from the years 2001-2019
scrape_attendance <- function(league) {
    
    # initialize a blank matrix
    stacked_attendance <- matrix(, nrow = 0, ncol = 13)
    
    for (year in years) {
        
        print(sprintf('Starting the year %s', year))
        
        full_url = paste(base_url, league, '/attendance/_/year/', year, sep='')
        
        # grab html
        data <- read_html(full_url)
        
        # select the final (season's end) league table
        table <- data %>%
            html_node('table') %>%
            html_table(fill=TRUE) # some tables had weird formatting
        
        # some processing
        colnames(table) = table[1,]  # the first row will be the header
        table = table[-1, ]          # removing the first row
        
        # add season to df
        season = paste(year-1, '-', year, sep='')
        table = cbind(Season=season, table)
        
        # renaming some (can't rbind without this)
        names(table)[2] <- 'Rank'
        names(table)[3] <- 'Team_Name'
        
        
        # add this year's data to the overall matrix `agg_matrix`
        stacked_attendance <- rbind(stacked_attendance, table)
        
    }
    
    outfile = paste(league, '_attendance.xlsx', sep='')
    
    # create a blank workbook
    wb <- createWorkbook()
    
    # create sheet
    addWorksheet(wb, outfile)
    
    # write to sheet
    writeData(wb, sheet = outfile, x = stacked_attendance)
    
    # save the workbook to `file_name`
    saveWorkbook(wb, file = outfile, overwrite = TRUE)
    
}

for (league in leagues) {
    
    print(sprintf('Scraping attendance for the %s', league))
    
    scrape_attendance(league)
}