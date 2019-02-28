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

