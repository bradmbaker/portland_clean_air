library(openxlsx)
library(dplyr)

setwd("~/Desktop/Portland_Clean_Air/combining_onsite_storage_and_permits/")

# read in onsite storaage and 
# convert address to a standardized format
# format is street, city, state 5 digit-zip
onsite_chem_storage_raw <- read.csv("raw_data/joined-filtered.tab", sep = "\t", stringsAsFactors = F)
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
deq_permits_mult_co <- read.xlsx("raw_data/rptSourcesMultnomahCounty.xlsx")
paste(
  deq_permits_mult_co$Site.Address,
  deq_permits_mult_co$`City,.State.Zip`,
  sep = ", "
) %>% sub("-[0-9]{4}","",.) -> deq_permits_mult_co$addr

# read in washington county data and 
# convert address to a standardized format
# format is street, city, state 5 digit-zip
deq_permits_wash_co <- read.xlsx("raw_data/rptSourcesWashingtonCounty.xlsx")
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

full_ds %>%
  rename(source_number_deq = Source.Number) %>%
  rename(company_name_deq = Source.Name) %>%
  rename(naics_code_deq = NAICS.Codes) %>%
  rename(permit_number_deq = Permit.Number) %>%
  rename(pca_website = DEQ.Permit.and.Review) %>%
  rename(address = addr) %>%
  rename(in_deq = in_deq_permits) %>%
  rename(company_name_storage = FacilityName) %>%
  rename(company_id_storage = FacilityID) %>%
  rename(company_type_storage = BusinessType) %>%
  rename(naics_code_storage = NAICS1) %>%
  rename(naics_code_description_storage = NAICSDesc1) %>%
  rename(chemical_name_storage = ChemName) %>%
  rename(hazardous_ingredient_storage = HazardousIngredient) %>%
  rename(average_amount_storage = AvgAmt) %>%
  rename(maximum_amount_storage = MaxAmt) %>%
  rename(storage_method_storage = StorageType1) %>%
  rename(hazardous_class_description_storage = HazClass1Desc) %>%
  rename(in_storage = in_chem_storage_data)-> full_ds

full_ds %>%
  select(source_number_deq, company_name_deq, naics_code_deq, 
         permit_number_deq, pca_website, address, in_deq, company_name_storage, 
         company_id_storage, company_type_storage, naics_code_storage, 
         naics_code_description_storage, chemical_name_storage, 
         hazardous_ingredient_storage, average_amount_storage, 
         maximum_amount_storage, storage_method_storage, 
         hazardous_class_description_storage, in_storage, key) -> full_ds

full_ds %>%
  mutate(company_name = coalesce(company_name_deq, company_name_storage)) -> full_ds

full_ds %>%
  select(company_name, address, key, in_deq, in_storage) %>%
  unique() %>%
  write.csv(., "cleaned_data/companies.csv")

full_ds %>%
  filter(in_deq == 1) %>%
  select(.,ends_with("deq"), key, address) %>% 
  unique() %>%
  write.csv(., "cleaned_data/deq_summary.csv")

full_ds %>%
  filter(in_storage == 1) %>%
  select(.,ends_with("storage"), key, address) %>% 
  unique() %>%
  write.csv(., "cleaned_data/storage_summary.csv")


