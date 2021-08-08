library(dplyr)
library(ggplot2)
library(stringr)
library(ggalt)

# merges multiple csvs together
multmerge = function(path){
    filenames = list.files(path=path, full.names=TRUE)
    
    datalist = lapply(filenames, function(x){
        read.csv(file = x, header = T)})
    
    Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

# merge the transfer data
transfer_data <- multmerge("data/transfer-data")

# merge results data
results_data <- multmerge("data/epl-results")

# only keep these columns
cols <- c("club_name", "fee_cleaned", "year", "transfer_movement", "season")
transfer_data <- transfer_data[cols]

# replace na's with 0's
transfer_data[is.na(transfer_data)] <- 0

# multiply "out" transfers by -1
transfer_data <- transfer_data %>%
    mutate(correct_fee = ifelse(transfer_movement == 'out', fee_cleaned * -1, fee_cleaned))

# calculate transfer spend ranking for ALL years
grouped_transfer_data <- transfer_data %>%
    group_by(club_name) %>%
    summarise(total_spend = sum(correct_fee))

grouped_transfer_data <- grouped_transfer_data %>%
    arrange(total_spend) %>%
    mutate(spend_rank = dense_rank(desc(total_spend)))

# rename `club_name` to `Team` for later join
grouped_transfer_data <- rename(grouped_transfer_data, Team = club_name)

# some regex work before joining
# trim year in the results df
# remove the (C) for Champion and (R) for relegated from Team name
results_data <- results_data %>% 
    mutate(season = year) %>%
    mutate(year = substr(year, start = 1, stop = 4)) %>%
    mutate(Team = str_replace_all(Team, " \\(\\S\\)", ""))

# rename transfer data team names to match results data
# remove FC and AFC from names then strip strings
grouped_transfer_data <- grouped_transfer_data %>%
    ungroup(Team) %>%
    mutate(Team = str_replace_all(Team, " FC", "")) %>%
    mutate(Team = str_replace_all(Team, "AFC", "")) %>%
    mutate(Team = trimws(Team))

# convert results_data `year` to numeric for later joining
results_data <- results_data %>%
    mutate(year = as.numeric(year))

# get average season-end position for each team
grouped_results_data <- results_data %>%
    group_by(Team) %>%
    summarise(avg_Pos = mean(Pos, na.rm = TRUE)) %>% 
    mutate(avg_Pos = round(avg_Pos, digits = 0))

# filter transfer data to top 10
top_10_spenders <- grouped_transfer_data %>%
    filter(spend_rank < 11)

# join transfers to results
data <- grouped_results_data %>% 
    right_join(top_10_spenders, by = c("Team")) %>%
    arrange(spend_rank)


############
# PLOTTING #
############

windowsFonts(poppins = windowsFont("Poppins"))


# Sort by spend rank and create a Team factor for ordering
data <- data %>% arrange(desc(spend_rank))

data$Team <- factor(data$Team, levels=as.character(data$Team))


# Spend Rank vs. Average Position plot
p <- ggplot(data, aes(x=avg_Pos, xend=spend_rank, y=Team)) + 
    #create a line between x and xend
    geom_segment(aes(x=avg_Pos, xend=spend_rank, y=Team, yend=Team), color="black", size=0.5) +
    # create dumbbells
    geom_dumbbell(color=NA, size_x=3, size_xend = 3, colour_x="#38003c",  colour_xend = "#00ff85") +
    # label rankings
    geom_text(aes(x=avg_Pos, label=avg_Pos, fontface="bold"), color="white", size=1.5) +
    geom_text(aes(x=spend_rank, label=spend_rank, fontface="bold"), color="black", size=1.5) + 
    # create a dummy legend
    # Spend Rank
    geom_rect(aes(xmin = 12.25, xmax = 14, ymin = 8.5, ymax = 9),
              fill = "#00ff85", color = "#00ff85", size = 1.5) + 
    annotate(geom="text", x=13.15, y=8.8, label="Spend Rank", size = 1.5) + 
    # Average Position
    geom_rect(aes(xmin = 12.25, xmax = 14, ymin = 8, ymax = 8.4),
              fill = "#38003c", color = "#38003c", size = 1.5) + 
    annotate(geom="text", x=13.15, y=8.25, label="Avg Pos", color="white", size = 1.5) +
    labs(x="\nPosition", y=NULL,  
         title="Buying wins?", 
         subtitle="Transfer Budget vs. Average Table Position (1992-2018)") +
    scale_x_continuous(breaks=seq(1,15, by=2)) + 
    theme(text = element_text(family = "poppins"),
          plot.title = element_text(face = "bold", color = "#38003c", size = 8),
          plot.subtitle = element_text(size = 5),
          plot.margin = margin(10, 10, 10, 30),
          axis.title.x = element_text(face = "bold", size = 5),
          axis.text = element_text(size = 5),
          axis.ticks = element_blank(),
          panel.background = element_blank(),
          panel.grid.major = element_line(colour = "#e0e0e0", linetype = "dashed", size=0.1),
          panel.grid.major.y = element_blank())



ggsave("plots/spend_vs_rank.png", p, width = 4, height = 3)


## failed animation
# see link below for moving labels and changing them
# https://stackoverflow.com/questions/58507077/gganimate-change-axes-between-frames
# the answer is probably in the below thread
# https://stackoverflow.com/questions/53162821/animated-sorted-bar-chart-with-bars-overtaking-each-other/53163549#53163549


# p <- ggplot(data, aes(x=Pos, xend=spend_rank, y=Team)) + 
#     geom_segment(aes(x=Pos, 
#                      xend=spend_rank, 
#                      y=Team, 
#                      yend=Team), 
#                  color="black", size=1)+
#     geom_dumbbell(color=NA,
#                   size_x=6, 
#                   size_xend = 6,
#                   #Note: there is no US:'color' for UK:'colour' 
#                   # in geom_dumbbel unlike standard geoms in ggplot()
#                   colour_x="#38003c", 
#                   colour_xend = "#00ff85")+
#     labs(x="Position", y=NULL, 
#          title="Spend vs. End of Season Rank", 
#          subtitle="1992-2018")+
#     geom_text(color="white", size=3, #hjust=-0.5,
#               aes(x=Pos, label=Pos, fontface="bold"))+
#     geom_text(aes(x=spend_rank, label=spend_rank, fontface="bold"), 
#               color="black", size=3) + #, hjust=1.5)
#     theme(plot.title = element_text(face = "bold", color = "#38003c"),
#           plot.subtitle = element_text(color = "#38003c"),
#           axis.title.x = element_text(face = "bold", color = "#38003c"),
#           axis.text.x = element_text(color = "#38003c"),
#           axis.text.y = element_text(color = "#38003c"),
#           panel.background = element_blank(),
#           panel.grid.major = element_line(colour = "#e0e0e0", linetype = "dashed", size=0.1))
# 
# animation <- p +  
#     labs(title = 'Spend vs. End of Season Rank: {closest_state}', y = 'Position') +
#     transition_states(year) +
#     ease_aes('linear')
# 
# animate(animation, renderer = gifski_renderer("gganim.gif"))
# 
# anim_save("filenamehere.gif", anim)


# This plotly works for one year but I can't sort out the year filter
# p <- plot_ly(temp, color = I("gray80")) %>%
#     add_segments(x = ~Pos, xend = ~spend_rank, y = ~Team, yend = ~Team, showlegend = FALSE) %>%
#     add_markers(x = ~Pos, y = ~Team, name = "Pos", color = I("pink")) %>%
#     add_markers(x = ~spend_rank, y = ~Team, name = "spend_rank", color = I("blue")) %>%
#     layout(
#         title = "Gender earnings disparity",
#         xaxis = list(title = "Annual Salary (in thousands)"),
#         margin = list(l = 65)
#     )


## This changes the data each year, but doesn't change axis labels
# gg <- ggplot(data, aes(x=Pos, xend=spend_rank, y=Team, frame=year)) + 
#     geom_segment(aes(x=Pos, 
#                      xend=spend_rank, 
#                      y=Team, 
#                      yend=Team), 
#                  color="#b2b2b2", size=1.5)+
#     geom_dumbbell(color="red", 
#                   size_x=3.5, 
#                   size_xend = 3.5,
#                   #Note: there is no US:'color' for UK:'colour' 
#                   # in geom_dumbbel unlike standard geoms in ggplot()
#                   colour_x="#edae52", 
#                   colour_xend = "#9fb059")+
#     labs(x=NULL, y=NULL, 
#          title="Dumbbell Chart", 
#          subtitle="Spend vs. End of Season Rank")+
#     geom_text(color="black", size=2, hjust=-0.5,
#               aes(x=Pos, label=Pos))+
#     geom_text(aes(x=spend_rank, label=spend_rank), 
#               color="black", size=2, hjust=1.5)
# 
# ggplotly(gg)
