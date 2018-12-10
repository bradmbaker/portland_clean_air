library(openxlsx)
library(dplyr)

setwd("~/Desktop/Portland_Clean_Air/combining_onsite_storage_and_permits/")

# read in onsite storaage and 
# convert address to a standardized format
# format is street, city, state 5 digit-zip
onsite_chem_storage_raw <- read.csv("joined-filtered.tab", sep = "\t")
paste(
  onsite_chem_storage_raw$LocAddress,
  ", ",
  onsite_chem_storage_raw$City,
  ", ",
  onsite_chem_storage_raw$StState,
  " ",
  substr(onsite_chem_storage_raw$StZip, 1, 5), 
  sep = ""
) %>%
  toupper() -> onsite_chem_storage_raw$addr 


# read in multnomah county data and 
# convert address to a standardized format
# format is street, city, state 5 digit-zip
deq_permits_mult_co <- read.xlsx("rptSourcesMultnomahCounty.xlsx")
paste(
  deq_permits_mult_co$Site.Address,
  deq_permits_mult_co$`City,.State.Zip`,
  sep = ", "
) %>% sub("-[0-9]{4}","",.) -> deq_permits_mult_co$addr

# read in washington county data and 
# convert address to a standardized format
# format is street, city, state 5 digit-zip
deq_permits_wash_co <- read.xlsx("rptSourcesWashingtonCounty.xlsx")
paste(
  deq_permits_wash_co$Site.Address,
  deq_permits_wash_co$`City,.State.Zip`,
  sep = ", "
) %>% sub("-[0-9]{4}","",.) -> deq_permits_wash_co$addr

# combine both deq datasets into one dataset.
deq_permits_wash_co$Operating.Status <- NA
names(deq_permits_wash_co)[names(deq_permits_wash_co) == "X7"] <- 'X8'
deq_permits <- rbind(deq_permits_mult_co, deq_permits_wash_co)
deq_permits$in_deq_permits <- 1

# only keep the relevant chemical storage data
# so it is more manageable
onsite_chem_storage_raw %>%
  select(FacilityID, FacilityName, BusinessType, 
         NAICS1, NAICSDesc1, NAICS2, NAICSDesc2, 
         ChemicalID, ChemName, HazardousIngredient, 
         AvgAmt, MaxAmt, UnitDesc, StorageType1, 
         HazClass1Desc, HazClass2Desc, addr) %>%
  mutate(in_chem_storage_data = 1) -> onsite_chem_storage_trim

# create one consolidated dataset with deq permits and onsite storage
# we'll create an arbitrary key rather than use the DEQ permit for the key.
full_join(deq_permits, onsite_chem_storage_trim, by = "addr") %>%
  mutate(addr_id = group_indices(.,addr)) %>%
  mutate(key = coalesce(Source.Number, paste('onsite_storage_',FacilityID, sep=""))) -> full_ds

write.csv(full_ds, "cleaned_data/deq_permits_and_onsite_storage.csv")
