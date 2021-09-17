library(prophet)
library(tidyverse)
library(lubridate)

# read csv, format dates, create monthly dates
trades <- read_csv(file = 'data/txns_with_party.csv') %>% 
  select(transaction_date, disclosure_date, party) %>% 
  mutate(transaction_date = format(as.Date(transaction_date, format = "%m/%d/%Y"), '%Y-%m-%d'),
         disclosure_date = format(as.Date(disclosure_date, format = "%m/%d/%Y"), '%Y-%m-%d'),
         txn_disc_daydiff = abs(floor(difftime(disclosure_date, transaction_date, units=c("days"))))) %>% 
  mutate(transaction_month = format(as.Date(transaction_date, format = '%Y-%m-%d'), '%Y-%m-%01'),
         disclosure_month = format(as.Date(disclosure_date, format = '%Y-%m-%d'), '%Y-%m-%01'))

# get count of txns per day
txn_dates <- trades %>% 
  select(transaction_date) %>% 
  group_by(transaction_date) %>% 
  summarise(count=n()) %>% 
  rename(ds = transaction_date, y = count)

# get count of disclosures per day
disc_dates <- trades %>% 
  select(disclosure_date) %>% 
  group_by(disclosure_date) %>% 
  summarise(count=n()) %>% 
  rename(ds = disclosure_date, y = count)

summary(txn_dates$y)
summary(disc_dates$y)

# remove outliers (> 3rd quartile)
txn_dates <- txn_dates %>% filter(y <= quantile(txn_dates$y, 0.75))
disc_dates <- disc_dates %>% filter(y <= quantile(disc_dates$y, 0.75))

# forecast transaction and disclosure dates
txn_model <- prophet(txn_dates)
txn_future <- make_future_dataframe(txn_model, periods = 365*3)
txn_forecast <- predict(txn_model, txn_future)

plot(txn_model, txn_forecast) + add_changepoints_to_plot(txn_model)

disc_model <- prophet(disc_dates)
disc_future <- make_future_dataframe(disc_model, periods = 365*3)
disc_forecast <- predict(txn_model, disc_future)

plot(disc_model, disc_forecast)

# try setting dates to the first of the month
# in order to aggregate monthly
txn_dates_monthly <- trades %>% select(transaction_month) %>%
  group_by(transaction_month) %>%
  summarise(count=n()) %>%
  rename(ds = transaction_month, y = count)

txn_model <- prophet(txn_dates_monthly)
txn_future <- make_future_dataframe(txn_model, periods = 365*3)
txn_forecast <- predict(txn_model, txn_future)

plot(txn_model, txn_forecast) + add_changepoints_to_plot(txn_model)


# average the count of transactions per month
txn_dates_monthly_avg <- trades %>% select(transaction_date) %>%
  group_by(transaction_date) %>%
  summarise(count=n()) %>%
  separate(transaction_date, c("year", "month", "day"), "-") %>%
  group_by(year, month) %>%
  summarise(avg = mean(count)) %>% 
  mutate(ds = paste(year, month, "01", sep="-")) %>% 
  ungroup() %>% 
  select(ds, avg) %>% 
  rename(y = avg)


txn_monthly_avg_model <- prophet(txn_dates_monthly_avg)
txn_monthly_avg_future <- make_future_dataframe(txn_monthly_avg_model, periods = 365*3)
txn_monthly_avg_forecast <- predict(txn_monthly_avg_model, txn_monthly_avg_future)

plot(txn_monthly_avg_model, txn_monthly_avg_forecast) + add_changepoints_to_plot(txn_monthly_avg_model)
# ^^ this is pretty similar to monthly counts ^^

# calculate the day difference
# between transaction date and disclosure date
daydiffs <- trades %>% 
  select(transaction_date, txn_disc_daydiff) %>% 
  rename(ds = transaction_date, y = txn_disc_daydiff) %>% 
  filter(y <= quantile(y, 0.75))

# forecast it
daydiff_model <- prophet(daydiffs)
daydiff_future <- make_future_dataframe(daydiff_model, periods = 365*3)
daydiff_forecast <- predict(daydiff_model, daydiff_future)

plot(daydiff_model, daydiff_forecast) + add_changepoints_to_plot(daydiff_model)

