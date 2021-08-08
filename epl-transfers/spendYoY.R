library(dplyr)
library(ggplot2)
library(plotly)

# merges multiple csvs together
multmerge = function(path){
    filenames = list.files(path=path, full.names=TRUE)
    
    datalist = lapply(filenames, function(x){
        read.csv(file = x, header = T)})
    
    Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

# merge the data
data <- multmerge("data/transfer-data")

# only keep these columns
cols <- c("position", "fee_cleaned", "year", "transfer_movement", "season")
data <- data[cols]

# replace na's with 0's
data[is.na(data)] <- 0

# multiply "out" transfers by -1 and sum by transfer movement
grouped_data <- data %>%
    mutate(correct_fee = ifelse(transfer_movement == "out", fee_cleaned * -1, fee_cleaned)) %>%
    group_by(year) %>%
    summarise(total_spend = sum(correct_fee))

# Taking inflation into account
inflation <- read.csv(file = "data/Inflation_Adjustment.csv", fileEncoding="UTF-8-BOM")

grouped_data <- grouped_data %>% 
    left_join(inflation, by="year") %>%
    mutate(inf_adj_spend = total_spend * (1 + .01 * Inflation))

# double checking the spend
# QC <- grouped_data %>% group_by(position) %>% summarise(sum(inf_adj_spend))

# calc average spend
avg_spend <- grouped_data %>% 
    summarize(Mean = mean(inf_adj_spend, na.rm=TRUE))

avg_spend <- pull(avg_spend)

############
# PLOTTING #
############

windowsFonts(poppins = windowsFont("Poppins"))


p <- ggplot(grouped_data, aes(x = year, y = inf_adj_spend)) +
    geom_line(linetype = "solid", size=1, color = "#00ff85") +
    geom_hline(yintercept = mean(grouped_data$inf_adj_spend), color="#e90052", linetype="dashed") +
    ggtitle("The market is going UP",
            subtitle = "Spend per year in the Prem (millions £)\n") +
    labs(x = "\nYear", y = "Spend\n") + 
    scale_x_continuous(breaks = pretty(grouped_data$year, n = 10)) +
    theme(text = element_text(family = "poppins"),
          plot.title = element_text(face = "bold", color = "#38003c", size = 8),
          plot.subtitle = element_text(size = 5),
          axis.title = element_text(face = "bold", size = 8),
          axis.line.x = element_line(),
          axis.text = element_text(size = 5),
          axis.ticks = element_blank(),
          panel.grid.major = element_line(colour = "#e0e0e0", linetype = "dashed", size=0.1),
          panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(), 
          panel.background = element_blank()) 


ggsave("total_spend_YoY.png", p, width = 4, height = 3)