#################################
####    LOAD DEPENDENCIES    ####
#################################

# load dependencies
if (!require('openxlsx')) install.packages('openxlsx')
library('openxlsx')
if (!require('rvest')) install.packages('rvest')
library('rvest')

# BY OFF DEF ST

base_url = 'https://www.nflpenalties.com/phase.php?year='

# a list of valid years
years = c('2009','2010','2011','2012','2013', '2014','2015','2016','2017','2018')

#########################
####    EXECUTION    ####
#########################

file_name = 'by_team_group.xlsx'

# create a blank workbook
wb <- createWorkbook()

for (year in years) {
    
    print(sprintf('Getting data for the year %s', year))
    
    # combine base url with the current year
    full_url <- paste(base_url, year, sep="")
    
    # read in the html
    data <- read_html(full_url)
    
    # select the only table in the html
    table <- data %>%
        html_node("table") %>%
        html_table()
    
    # create sheet
    addWorksheet(wb, year)
    
    # write to sheet
    writeData(wb, sheet = year, x = table)
    
    print(sprintf('Done with %s', year))

}

# save the workbook to `file_name`
saveWorkbook(wb, file = file_name, overwrite = TRUE)