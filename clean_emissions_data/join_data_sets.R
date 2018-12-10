library(dplyr)
library(stringr)
setwd("~/Desktop/Portland_Clean_Air/")

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
  mutate(is_unfiltered_emissions = ifelse(x_control == "x", "T", "F")) %>%
  mutate(clean_desc_row_id = as.numeric(desc_row_id)) ->
  deq_cas_data_descriptors

# step 2b
# there's 34 bad rows of data in the CAS dataset of total 4418 rows.
# i'm just going to toss it for now but it should probably be cleaned
# you can see the bad data with this statement but the issue is the desc_row_id is missing
# View(deq_cas_data_descriptors[is.na(deq_cas_data_descriptors$clean_desc_row_id),])
deq_cas_data_descriptors %>% 
  filter(!is.na(clean_desc_row_id)) %>%
  select(clean_desc_row_id, is_unfiltered_emissions) ->
  deq_cas_data_descriptors_clean 

# step 3
# take all emissions data and join in whether the emissions are unfiltered
all_emissions_data <- left_join(deq_emission_w_co, 
                                deq_cas_data_descriptors_clean, 
                                by = c("desc_row_id" = "clean_desc_row_id"))
deq_cas_data_descriptors_clean[deq_cas_data_descriptors_clean$clean_desc_row_id == 3794,]

# step 4
# This is a TODO
# there is some bad data here that is getting coerced into NAs.
# At some point we'll need to fix it. It looks like it affects 3k rows of the 37k.
# what does "See Note 1" mean in the data_a column mean?

all_emissions_data %>%
  filter(data_a != " ") %>% # when data_a is blank this is a piece of summary data
  mutate(clean_data_a = as.numeric(data_a)) %>%
  mutate(clean_data_b = ifelse(data_b == " ",0, as.numeric(data_b))) %>%
  mutate(clean_data_c = ifelse(data_c == " ",0, as.numeric(data_c))) -> all_emissions_data

# step 5
# reduce dataset to only unfitered emissions
all_emissions_data %>%
  filter(is_unfiltered_emissions == "T") -> all_unfiltered_emissions

# step 6 
# aggregate data by summing by pollutant type
all_unfiltered_emissions %>% 
  group_by(company.source.no, 
           filename,
           st.addr, 
           city.addr,
           zip.addr,
           facility.name, 
           cas_code, 
           cas_name, 
           unit_a, 
           unit_b, 
           unit_c) %>%
  summarise(total_data_a = sum(clean_data_a, na.rm = T), 
            total_data_b = sum(clean_data_b, na.rm = T),
            total_data_c = sum(clean_data_c, na.rm = T)) -> all_unfiltered_emissions_summary

# step 7
# save to csv
write.csv(all_unfiltered_emissions_summary, "unfiltered_data_summary.csv")

# step 8 
# do a basic analysis to see top polluters for most frequent appearing pollutants

# top 10 pollutants
all_unfiltered_emissions_summary %>%
  group_by(cas_name) %>%
  summarise(n = n()) %>%
  arrange(-n) %>%
  top_n(10) %>%
  select(cas_name) %>%
  unlist(use.names = F)-> top_cas

all_unfiltered_emissions_summary %>%
  filter(cas_name %in% top_cas) %>%
  group_by(cas_name) %>%
  filter(total_data_a == max(total_data_a)) -> worst_offenders_by_top_pollutants

write.csv(worst_offenders_by_top_pollutants, "worst_offenders.csv")
View(worst_offenders_by_top_pollutants)
