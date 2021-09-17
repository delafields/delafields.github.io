library(prophet)
library(tidyverse)
library(lubridate)

trades <- read_csv(file = 'data/txns_with_party.csv') %>% 
  select(transaction_date, disclosure_date, party) %>% 
  mutate(transaction_date = format(as.Date(transaction_date, format = "%m/%d/%Y"), '%Y-%m-%d'),
         disclosure_date = format(as.Date(disclosure_date, format = "%m/%d/%Y"), '%Y-%m-%d'))

txn_dates <- trades %>% 
  select(transaction_date) %>% 
  group_by(transaction_date) %>% 
  summarise(count=n()) %>% 
  rename(ds = transaction_date, y = count)

disc_dates <- trades %>% 
  select(disclosure_date) %>% 
  group_by(disclosure_date) %>% 
  summarise(count=n()) %>% 
  rename(ds = disclosure_date, y = count)

txn_model <- prophet(txn_dates)
txn_future <- make_future_dataframe(txn_model, periods = 365*3)
txn_forecast <- predict(txn_model, txn_future)

plot(txn_model, txn_forecast) + add_changepoints_to_plot(txn_model)

disc_model <- prophet(disc_dates)
disc_future <- make_future_dataframe(disc_model, periods = 365*3)
disc_forecast <- predict(txn_model, disc_future)

plot(disc_model, disc_forecast)

# removing outliers
summary(txn_dates$y)

txn_dates_filtered <- txn_dates %>% filter(y <= 5)

txn_model <- prophet(txn_dates_filtered)
txn_future <- make_future_dataframe(txn_model, periods = 365*3)
txn_forecast <- predict(txn_model, txn_future)

plot(txn_model, txn_forecast) + add_changepoints_to_plot(txn_model)

# try setting dates to the first of the month
txn_dates_monthly <- trades %>% select(transaction_date) %>%
  mutate(transaction_date = format(as.Date(transaction_date, format = '%Y-%m-%d'), '%Y-%m-%01')) %>%
  group_by(transaction_date) %>%
  summarise(count=n()) %>%
  rename(ds = transaction_date, y = count)

txn_model <- prophet(txn_dates_monthly)
txn_future <- make_future_dataframe(txn_model, periods = 365*3)
txn_forecast <- predict(txn_model, txn_future)

plot(txn_model, txn_forecast) + add_changepoints_to_plot(txn_model)


# try averaging per month
txn_dates_monthly_avg <- trades %>% select(transaction_date) %>%
    # mutate(transaction_date = format(as.Date(transaction_date, format = '%Y-%m-%d'), '%Y-%m-%01')) %>%
    group_by(transaction_date) %>%
    summarise(count=n()) %>%
    separate(transaction_date, c("year", "month", "day"), "-") %>%
  group_by(year, month) %>%
  summarise(avg = mean(count)) %>% 
  mutate(ds = paste(year, month, "01", sep="-")) %>% 
  ungroup() %>% 
  select(ds, avg) %>% 
  rename(y = avg)


txn_model <- prophet(txn_dates_monthly_avg)
txn_future <- make_future_dataframe(txn_model, periods = 365*3)
txn_forecast <- predict(txn_model, txn_future)

plot(txn_model, txn_forecast) + add_changepoints_to_plot(txn_model)

