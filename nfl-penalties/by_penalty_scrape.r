#################################
####    LOAD DEPENDENCIES    ####
#################################

# load dependencies
if (!require('openxlsx')) install.packages('openxlsx')
library('openxlsx')
if (!require('rvest')) install.packages('rvest')
library('rvest')



################################
####    HELPER FUNCTIONS    ####
################################

# this scrapes data for an individual penalty for an individual year
# returns a matrix
scrape_penalties <- function (penalty, year, penalty_outcome) {
    
    print(sprintf('Scraping %s for the year %s', penalty, year))

    # combine the base url with the penalty and year
    full_url = paste(base_url, penalty, url_param, year, sep="")
    
    print(sprintf('Trying to open the url %s', full_url))
    
    # read in the html
    data <- read_html(full_url)
    
    # select the only table in the html
    table <- data %>%
        html_node("table") %>%
        html_table()
    
    # converting the table html to a matrix
    temp <- as.matrix(table)
    
    # some processing
    colnames(temp) = temp[1, ]       # the first row will be the header
    penalty_df = temp[-1, ]          # removing the first row (it's a grouped table)
    penalty_df <- penalty_df[, 1:7]  # select only 'Against' columns
    
    # adding a column for year and penalty yardage
    penalty_df <- cbind(penalty_df, Penalty_Outcome=penalty_outcome, Year=year)
    
    print('Success')
    
    return(penalty_df)
}

# combines every year's data for a specific penalty (uses `scrape_penalties()` to acheive this)
# returns a matrix
create_workbook <- function(penalty, penalty_yardage) {
    
    print(sprintf('Getting the data for %s', penalty))
    
    # initialize a blank matrix
    agg_matrix <- matrix(, nrow = 0, ncol = 9)
    
    for (year in years) {
        
        # scrape data for this year
        temp <- scrape_penalties(penalty, year, penalty_yardage)
        
        # add this year's data to the overall matrix `agg_matrix`
        agg_matrix <- rbind(agg_matrix, temp)
        
    }
    
    print(sprintf('Successfully got all of the data for %s', penalty))
    
    return(agg_matrix)
    
}

# returns the correct yardage for groups of penalties
get_penalty_yardage <- function(penalty) {
    if (penalty %in% spot_penalties) { return(111) } 
    else if (penalty %in% weird_penalties) { return(999) }
    #else if (penalty %in% thirty_yard_penalties) { return(30) }
    else if (penalty %in% fifteen_yard_penalties) { return(15) }
    else if (penalty %in% ten_yard_penalties) { return(10) }
    else if (penalty %in% five_yard_penalties) { return(5) }
    else return(555)
}



#################################
####    GLOBAL PARAMETERS    ####
#################################

# base url of the BY-penalty data
base_url <- "https://www.nflpenalties.com/penalty/"

# url param for year
url_param <- "?year="

# a list of valid years
years = c('2009','2010','2011','2012','2013', '2014','2015','2016','2017','2018')

# penalty lists for getting yardage
all_penalties <- c('defensive-pass-interference','illegal-touch-kick','intentional-grounding','illegal-use-of-hands','fair-catch-interference','illegal-blindside-block','clipping','low-block','unnecessary-roughness','roughing-the-passer','face-mask-15-yards','unsportsmanlike-conduct','taunting','horse-collar-tackle','chop-block','disqualification','roughing-the-kicker','offensive-holding','illegal-block-above-the-waist','offensive-pass-interference','tripping','illegal-forward-pass','illegal-touch-pass','defensive-delay-of-game','false-start','defensive-holding','defensive-offside','neutral-zone-infraction','delay-of-game','illegal-formation','illegal-shift','encroachment','illegal-contact','ineligible-downfield-pass','offside-on-free-kick','illegal-motion','illegal-substitution','ineligible-downfield-kick','running-into-the-kicker')
# penalties that we don't have full data for: c('illegal-crackback','leverage','kick-catch-interference','leaping','illegal-bat','lowering-the-head-to-initiate-contact','invalid-fair-catch-signal','defensive-too-many-men-on-field','offensive-too-many-men-on-field','player-out-of-bounds-on-kick','kickoff-out-of-bounds')

# penalties in their correct yardage group
spot_penalties <- c('defensive-pass-interference','illegal-touch-kick')
weird_penalties <- c('intentional-grounding','illegal-use-of-hands')
fifteen_yard_penalties <- c('fair-catch-interference','illegal-blindside-block','illegal-crackback','leverage','clipping','kick-catch-interference','leaping','low-block','unnecessary-roughness','roughing-the-passer','face-mask-15-yards','unsportsmanlike-conduct','taunting','horse-collar-tackle','lowering-the-head-to-initiate-contact','chop-block','disqualification','roughing-the-kicker')
ten_yard_penalties <- c('offensive-holding','illegal-block-above-the-waist','offensive-pass-interference','tripping')
five_yard_penalties <- c('illegal-forward-pass','illegal-touch-pass','defensive-delay-of-game','invalid-fair-catch-signal','false-start','defensive-holding','defensive-offside','neutral-zone-infraction','delay-of-game','illegal-formation','defensive-too-many-men-on-field','illegal-shift','encroachment','illegal-contact','ineligible-downfield-pass','offside-on-free-kick','illegal-motion','illegal-substitution','ineligible-downfield-kick','offensive-too-many-men-on-field','player-out-of-bounds-on-kick','running-into-the-kicker')



#########################
####    EXECUTION    ####
#########################

file_name = 'by_penalty.xlsx'

# create a blank workbook
wb <- createWorkbook()

# loop through each penalty & create a sheet for it in the workbook `wb`
for (p in all_penalties) {
    
    sprintf('Starting penalty %s', p)
    
    # get yardage
    yardage <- get_penalty_yardage(p)
    
    # create sheet
    addWorksheet(wb, p)
    
    # get data
    data <- create_workbook(penalty = p, penalty_yardage = yardage)
    
    # write to sheet
    writeData(wb, sheet = p, x = data)
    
} 

# save the workbook to `file_name`
saveWorkbook(wb, file = file_name, overwrite = TRUE)