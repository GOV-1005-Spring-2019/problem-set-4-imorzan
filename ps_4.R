library(gt)
library(tidyverse)
library(janitor)
library(lubridate)

data <- read_csv(file = "ps_4_elections-poll-nc09-3.csv",
  col_types = cols(
    .default = col_character(),
    turnout_scale = col_double(),
    turnout_score = col_double(),
    w_LV = col_double(),
    w_RV = col_double(),
    final_weight = col_double(),
    timestamp = col_datetime(format = ""))) %>%
    clean_names() %>%
    filter(!is.na(response), !is.na(race_eth), !is.na(final_weight), educ != "[DO NOT READ] Refused")

table <- data %>% 
  select(response, race_eth, final_weight) %>% 
  mutate(race_eth = fct_relevel(race_eth, c("White", "Black", "Hispanic", "Asian", "Other"))) %>%
  group_by(race_eth, response) %>%
  summarize(total = sum(final_weight)) %>%   
  filter(race_eth != "[DO NOT READ] Don't know/Refused") %>% 
  spread(key =  response, value = total, fill = 0) %>% 
  ungroup() %>%
  mutate(all = Dem + Rep + Und + `3`) %>% 
  mutate(Dem = Dem / all) %>% 
  mutate(Rep = Rep / all) %>% 
  mutate(Und = Und / all) %>% 
  select(-`3`, -all)

gt(table) %>% 
  tab_header(title = "Vote Spread by Ethnicity") %>% 
  cols_label(
    race_eth = "",
    Dem = "DEM.",
    Rep = "REP.",
    Und = "UND."
  ) %>%
  fmt_percent(columns = vars(Dem, Rep, Und), decimals = 0) %>% 
  # This little pipe is that incantation to take this pretty table, turn it
  # into html, and send it to the md file we are creating.
  na_if(0) %>%
  fmt_missing(columns = vars(Und), rows = 4, missing_text = "---") %>%
  # A title and source label is assigned
  tab_header(title = "Polling Data from 3rd Wave for North Carolina's 9th Congressional District") %>% 
  tab_source_note(source_note = "Source: New York Times Upshot/Siena College 2018 live polls") %>% 
  as_raw_html() %>% 
  as.character() %>% 
  cat()
