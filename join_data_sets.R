library(dplyr)
library(stringr)
setwd("~/Desktop/Portland Clean Air/")

# company level details
deq_co_details <- read.csv("2016_deq_co_details.csv", stringsAsFactors = F)
# emissions details
deq_emission <- read.csv("2016_deq_emission_clean.csv", stringsAsFactors = F)
# emissions controls data
deq_cas_data_descriptors <- read.csv("NEW 2016_deq_cas_data_descriptors.csv", 
                                     col.names = c(
                                       "desc_row_id",
                                       "b", "c", "d", "e", "f", "g", "h", "i","j",
                                       "x_control",
                                       "l", "m", "n", "o", "p", "q", "r", "s", "t",
                                       "u", "v", "w", "x", "y", "z", "aa", "ab", "ac",
                                       "ad", "ae", "af"
                                       
                                     ), stringsAsFactors = F)

# step 1 
# pull company name and data into deq_emission table
deq_emission_w_co <- left_join(deq_co_details, 
                               deq_emission, 
                               by = c("company.source.no" = "coSourceNo"))

# step 2
# add a more intuitive flag for if emissions controls are in place
deq_cas_data_descriptors %>%
  mutate(has_emissions_control_in_use = ifelse(x_control == "x", "F", "T")) %>%
  mutate(clean_desc_row_id = as.numeric(desc_row_id)) ->
  deq_cas_data_descriptors

# step 2b
# there's 34 bad rows of data in the CAS dataset of total 4418 rows.
# i'm just going to toss it for now but it should probably be cleaned
# you can see the bad data with this statement but the issue is the desc_row_id is missing
# View(deq_cas_data_descriptors[is.na(deq_cas_data_descriptors$clean_desc_row_id),])
deq_cas_data_descriptors %>% 
  filter(!is.na(clean_desc_row_id)) %>%
  select(clean_desc_row_id, has_emissions_control_in_use) ->
  deq_cas_data_descriptors_clean 

# step 3
# NOTE THIS ASSUMPTION IS PROBABLY WRONG
# join in emissions controls data and remove all companies that have 
# emission controls in place.
# NOTE THIS ASSUMPTION IS PROBABLY WRONG
all_emissions_data <- left_join(deq_emission_w_co, 
                                deq_cas_data_descriptors_clean, 
                                by = c("desc_row_id" = "clean_desc_row_id"))

# this sets the air filter flag
# it is defined as all rows in which a filter is not being used per the CAS data set
# or rows in which there was no data in the CAS dataset
all_emissions_data %>%
  mutate(emission_control = !(has_emissions_control_in_use == "T" )) ->
  all_emissions_data


# step 4
# Tossing out all bad data_a rows
# tossing out bad rows accounts for 2046 rows of 37k
# 700 rows are blank, then "See Note 1", then a bunch of garbage.
# what does "See Note 1" mean in the data_a column mean?

all_emissions_data %>%
  mutate(clean_data_a = as.numeric(data_a)) %>%
  filter(!is.na(clean_data_a)) -> all_emissions_data

# top 10 pollutants
all_emissions_data %>%
  filter(emission_control == F) %>%
  group_by(cas_name) %>%
  summarise(n = n()) %>%
  arrange(-n) %>%
  top_n(10) %>%
  select(cas_name) %>%
  unlist(use.names = F)-> top_cas

all_emissions_data %>%
  filter(emission_control == F) %>%
  filter(cas_name %in% top_cas) %>%
  group_by(cas_name) %>%
  filter(clean_data_a == max(clean_data_a)) %>%
  View


View(deq_co_details)
deq_co_details %>%
  group_by(company.source.no) %>%
  summarise(n = n()) %>%
  group_by(n) %>%
  summarise(n2 = n())

View(head(deq_emission))
str(deq_emission)

deq_emission_w_co %>%
  filter(str_detect(facility.name, "PCC")) %>% 
  filter(str_detect(cas_name, "ethyl benzene")) %>% View



%>% View
?starts_with
