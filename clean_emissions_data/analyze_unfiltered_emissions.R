library(dplyr)

setwd("~/Desktop/Portland_Clean_Air/")

all_unfiltered_emissions <- read.csv("all_unfiltered_emissions.csv", stringsAsFactors = F)




all_unfiltered_emissions %>%
  filter(cas_name %in% top_cas) %>%
  group_by(cas_name) %>%
  filter(clean_data_a == max(clean_data_a)) %>%
  View

deq_emission


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

### double check
library(data.table)
all_unfiltered_emissions_summary %>%
  filter(facility.name %like% "Owens-Brockway") %>% View

# 6090 for Owens-Brockway sum of column b
all_unfiltered_emissions_summary %>% 
  filter(facility.name %like% "Owens-Brockway") %>%
  filter(cas_name == " lead") %>%
  group_by(facility.name) %>%
  summarise(total_p = sum(total_data_b))

deq_emission %>%
  filter(coSourceNo == "26-1876") -> owens_emissions
sum(as.numeric(owens_emissions$data_b))
str(deq_cas_data_descriptors_clean)
is.null(owens_emissions$data_a )
owens_emissions %>%
  filter(data_a == " ") %>% View
left_join(owens_emissions, 
          deq_cas_data_descriptors_clean, 
          by = c("desc_row_id" = "clean_desc_row_id")) -> owens_all
owens_all %>% group_by(is_unfiltered_emissions) %>% summarise(t = sum(as.numeric(data_b)))



  mutate(clean_a = as.numeric(data_a),
         clean_b = as.numeric(data_b)) %>% View
  summarise(sum(clean_b))
