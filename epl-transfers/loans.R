library(dplyr)
library(ggplot2)
library(stringr)
library(cowplot)

# merges multiple csvs together
multmerge = function(path){
    filenames = list.files(path=path, full.names=TRUE)
    
    datalist = lapply(filenames, function(x){
        read.csv(file = x, header = T)})
    
    Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

# merge all transfer data
transfer_data <- multmerge("data/transfer-data")

# narrow to where fee = `Loan`
loans <- transfer_data %>%
    filter(str_detect(fee, "Loan"))

# get counts of loans in/out per team
loans_per_team <- loans %>%
    group_by(club_name) %>%
    count(transfer_movement) %>%
    rename("num_loans" = n)

# get loans per year
loans_per_year <- loans %>%
    group_by(year) %>%
    count(transfer_movement) %>%
    rename("num_loans" = n)

##################
# WAYS TO FILTER #
##################

# see who's been in the league this whole period
tenure <- loans %>% 
    select(club_name, year) %>% 
    distinct() %>% 
    count(club_name) %>% 
    arrange(desc(n)) %>%
    rename("years_of_data" = n)

# narrow to teams with > 40 loans
over_40 <- loans_per_team %>%
    group_by(club_name) %>%
    summarise(total_loans = sum(num_loans)) %>%
    filter(total_loans > 40)

loans_per_team <- loans_per_team %>% right_join(over_40)

# EVEN FURTHER narrow to top 20 loaners
loans_per_team <- loans_per_team %>% 
    arrange(desc(total_loans)) %>%
    .[1:40, ]

############
# PLOTTING #
############

windowsFonts(poppins = windowsFont("Poppins"))

# Loans per year plot
lpy <- ggplot(loans_per_year, aes(year, num_loans, group=transfer_movement, color=transfer_movement)) + 
    geom_line(size = 1) + 
    ggtitle("Out on loan", subtitle="Premier League loans in & loans out (1992 - 2018)") +
    labs(color = "Transfer Movement   ", x = "\nYear", y = "# of Loans\n") +
    scale_y_continuous(breaks = pretty(loans_per_year$num_loans, n = 10)) + 
    scale_x_continuous(breaks = pretty(loans_per_year$year, n = 10)) + 
    scale_color_manual(values = c("#00ff85", "#e90052")) + 
    theme(text = element_text(family = "poppins"), 
          plot.title = element_text(face = "bold", color = "#38003c", size = 8),
          plot.subtitle = element_text(size = 5),
          axis.title = element_text(face = "bold", size = 8),
          axis.text = element_text(size = 5),
          axis.ticks = element_blank(),
          panel.background = element_rect(fill = 'white'),
          panel.grid.major = element_line(colour = "#e0e0e0", linetype = "dashed", size=0.1),
          panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank(),
          legend.position = c(0.2, 0.75),
          legend.background = element_rect(linetype="solid", color = "black"),
          legend.key=element_rect(fill='white'),
          legend.title = element_text(face = "bold", size = 5),
          legend.key.size  = unit(0.25, 'cm'),
          legend.text  = element_text(size = 5))

lpy

ggsave("loans_YoY.png", lpy, width = 4, height = 3)

# Loans per team plot
lpt <- ggplot(data=loans_per_team, aes(x = reorder(club_name, num_loans), y = num_loans, fill=transfer_movement, label = num_loans)) + 
    geom_bar(stat="identity", color = "#38003c", size = 0.5) + 
    coord_flip() + 
    geom_text(size = 2, position = position_stack(vjust = 0.5)) +
    ggtitle("Chelsea leads the way", subtitle="Premier League loans per team (1992 - 2018)") +
    labs(x = "Club", y = "# of Loans", fill="Transfer Movement") +
    scale_fill_manual(values = c("#00ff85", "#e90052")) + 
    theme(text = element_text(family = "poppins"),
          plot.title = element_text(face = "bold", color = "#38003c", size = 8),
          plot.subtitle = element_text(size = 6),
          axis.title = element_text(face = "bold", size = 8),
          axis.text = element_text(size = 5),
          axis.ticks = element_blank(),
          axis.title.y = element_blank(),
          panel.background = element_rect(fill = 'white'),
          panel.grid.major = element_line(colour = "#e0e0e0", linetype = "dashed", size=0.1),
          panel.grid.major.y = element_blank(),
          panel.grid.minor = element_blank(),
          legend.position = c(0.7, 0.2),
          legend.background = element_rect(linetype="solid", color = "black"),
          legend.key=element_rect(fill='white'),
          legend.title = element_text(face = "bold", size = 5),
          legend.key.size  = unit(0.25, 'cm'),
          legend.text  = element_text(size = 5))

lpt

ggsave("loans_per_team.png", lpt, width = 4, height = 3)


# Loans per team by transfer movement
loans_in <- loans_per_team %>% filter(transfer_movement == "in")
loans_out <- loans_per_team %>% filter(transfer_movement == "out")

outp <- ggplot(data=loans_out, aes(x = reorder(club_name, num_loans), y = num_loans, label = num_loans)) + 
    geom_bar(stat="identity", color = "#38003c", fill="#e90052", size = 0.5) + 
    coord_flip() + 
    ggtitle("Loans In", subtitle="EPL Top 20 Loaners") +
    labs(color = "Transfer Movement", x = "\nClub", y = "\n# of Loans Out") +
    geom_text(size = 2, position = position_stack(vjust = 0.5)) + 
    theme(text = element_text(family = "poppins"),
          plot.title = element_text(face = "bold", color = "#38003c", size = 8),
          plot.subtitle = element_text(size = 5),
          axis.title = element_blank(),
          axis.text = element_text(size = 5),
          axis.ticks = element_blank(),
          panel.background = element_rect(fill = 'white'),
          panel.grid.major = element_line(colour = "#e0e0e0", linetype = "dashed", size=0.1),
          panel.grid.major.y = element_blank(),
          panel.grid.minor = element_blank(),
          legend.position = c(0.9, 0.2),
          legend.title = element_text(face = "bold", size = 5),
          legend.text  = element_text(size = 4),
          legend.key.size  = unit(0.25, 'cm'),
          legend.key=element_rect(fill='white'))

inp <- ggplot(data=loans_in, aes(x = reorder(club_name, num_loans), y = num_loans, label = num_loans)) + 
    geom_bar(stat="identity", color = "#38003c", fill="#00ff85", size = 0.5) + 
    coord_flip() + 
    ggtitle("Loans Out", subtitle=" ") +
    labs(color = "Transfer Movement", x = "\nClub", y = "\n# of Loans In") + 
    geom_text(size = 2, position = position_stack(vjust = 0.5)) + 
    theme(text = element_text(family = "poppins"),
          plot.title = element_text(face = "bold", color = "#38003c", size = 8),
          plot.subtitle = element_text(size = 5),
          axis.title = element_blank(),
          axis.text = element_text(size = 5),
          axis.ticks = element_blank(),
          panel.background = element_rect(fill = 'white'),
          panel.grid.major = element_line(colour = "#e0e0e0", linetype = "dashed", size=0.1),
          panel.grid.major.y = element_blank(),
          panel.grid.minor = element_blank(),
          legend.position = c(0.9, 0.2),
          legend.title = element_text(face = "bold", size = 5),
          legend.text  = element_text(size = 4),
          legend.key.size  = unit(0.25, 'cm'),
          legend.key=element_rect(fill='white'))

split <- plot_grid(outp, inp, ncol=2)

ggsave("loans_by_movementNteam.png", split, width = 4, height = 3.5)