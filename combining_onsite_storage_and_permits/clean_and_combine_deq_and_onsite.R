library(openxlsx)
library(dplyr)
library(ggmap)

setwd("~/Desktop/Portland_Clean_Air/combining_onsite_storage_and_permits/")


#######
# Data Set 1 - Onsite Chemical Storage
#######
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
  toupper() -> onsite_chem_storage_raw$address 

# only keep the relevant chemical storage data
# so it is more manageable
onsite_chem_storage_raw %>%
  select(FacilityID, FacilityName, BusinessType, 
         NAICS1, NAICSDesc1, NAICS2, NAICSDesc2, 
         ChemicalID, ChemName, HazardousIngredient, 
         AvgAmt, MaxAmt, UnitDesc, StorageType1, 
         HazClass1Desc, HazClass2Desc, Latitude, Longitude, address) %>%
  mutate(in_storage = 1) %>%
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
  rename(lat = Latitude) %>%
  rename(lng = Longitude) -> onsite_chem_storage_trim


#######
# Data Set 2 - Multnomah County DEQ Permits
#######
# read in multnomah county data and 
# convert address to a standardized format
# format is street, city, state 5 digit-zip
deq_permits_mult_co <- read.xlsx("raw_data/rptSourcesMultnomahCounty.xlsx")
paste(
  deq_permits_mult_co$Site.Address,
  deq_permits_mult_co$`City,.State.Zip`,
  sep = ", "
) %>% sub("-[0-9]{4}","",.) -> deq_permits_mult_co$address


#######
# Data Set 3 - Washington County DEQ Permits
#######
# read in washington county data and 
# convert address to a standardized format
# format is street, city, state 5 digit-zip
deq_permits_wash_co <- read.xlsx("raw_data/rptSourcesWashingtonCounty.xlsx")
paste(
  deq_permits_wash_co$Site.Address,
  deq_permits_wash_co$`City,.State.Zip`,
  sep = ", "
) %>% sub("-[0-9]{4}","",.) -> deq_permits_wash_co$address

# combine both deq datasets into one dataset.
deq_permits_wash_co$Operating.Status <- NA
names(deq_permits_wash_co)[names(deq_permits_wash_co) == "X7"] <- 'X8'
deq_permits <- rbind(deq_permits_mult_co, deq_permits_wash_co)
deq_permits$in_deq_permits <- 1

# rename the columns to make more sense
deq_permits %>%
  rename(source_number_deq = Source.Number) %>%
  rename(company_name_deq = Source.Name) %>%
  rename(naics_code_deq = NAICS.Codes) %>%
  rename(permit_number_deq = Permit.Number) %>%
  rename(general_type_permit_deq = X8) %>%
  rename(pca_website = DEQ.Permit.and.Review) %>%
  rename(in_deq = in_deq_permits) %>%
  select(ends_with("deq"), address, pca_website) -> deq_permits 

  
#####
# Data Set 4 - Railyards
#####
railyards <- read.xlsx("raw_data/NEI PCA railyards.xlsx")
railyards %>%
  rename(site_name_railyard = facility_site_name) %>%
  rename(lat = latitude_msr) %>%
  rename(lng = longitude_msr) %>%
  mutate(in_railyard = 1) %>%
  select(ends_with("railyard"), lat, lng) -> railyards

#####
# Data Set 5 - Airports
#####
airports <- read.xlsx("raw_data/NEI clack, mult, Wash airports final.xlsx", 
                      colNames = F)
airports %>%
  rename(id_airport = X1) %>%
  rename(county_airport = X3) %>%
  rename(lat = X6) %>%
  rename(lng = X7) %>%
  rename(site_name_airport = X4) %>%
  mutate(in_airport = 1) %>%
  select(ends_with("airport"), lat, lng) -> airports

#####
# Data Set 6 - Washington County No Permit Polluters
#####
wash_co_no_permit_polluters <- read.xlsx("raw_data/wash county no permit polluters.xlsx")
wash_co_no_permit_polluters %>%
  mutate(StZip = substr(StZip, 1, 5)) %>%
  mutate(address = paste(LocAddress, ", ", City, ", OR ", StZip, sep = "")) %>%
  mutate(in_wash_co_no_permit = 1) %>%
  rename(site_name_wash_co_no_permit = FacilityName) %>%
  select(ends_with("no_permit"), address) -> wash_co_no_permit_polluters


#####
# Combine DEQ Permits and Onsite Storage Data
# These are combined because they have more info that can go on individual websites.
#####
# create one consolidated dataset with deq permits and onsite storage
# we'll create an arbitrary key rather than use the DEQ permit for the key.
full_join(deq_permits, onsite_chem_storage_trim, by = "address") %>%
  mutate(address_id = group_indices(.,address)) %>%
  mutate(key = coalesce(source_number_deq, paste('onsite_storage_',company_id_storage, sep=""))) -> full_ds

full_ds %>%
  select(source_number_deq, company_name_deq, naics_code_deq, 
         permit_number_deq, general_type_permit_deq, 
         pca_website, address, lat, lng, in_deq, company_name_storage, 
         company_id_storage, company_type_storage, naics_code_storage, 
         naics_code_description_storage, chemical_name_storage, 
         hazardous_ingredient_storage, average_amount_storage, 
         maximum_amount_storage, storage_method_storage, 
         hazardous_class_description_storage, in_storage, key) -> full_ds

full_ds %>%
  mutate(company_name = coalesce(company_name_deq, company_name_storage)) -> full_ds

#####
# save these datasets to make individual websites
#####

full_ds %>%
  select(company_name, address, key, in_deq, in_storage) %>%
  unique() %>%
  write.csv(., "cleaned_data/companies.csv", row.names = F)

full_ds %>%
  filter(in_deq == 1) %>%
  select(.,ends_with("deq"), key, address) %>% 
  unique() %>%
  write.csv(., "cleaned_data/deq_summary.csv", row.names = F)

full_ds %>%
  filter(in_storage == 1) %>%
  select(.,ends_with("storage"), key, address) %>% 
  unique() %>%
  write.csv(., "cleaned_data/storage_summary.csv", row.names = F)

#####
# clean up the data so what is displayed on maps is simple and easy to read.
# if it's already been done, the if statement skips this step
##### 
full_ds %>%
  select(company_name, address, key, in_deq, in_storage, general_type_permit_deq) %>%
  unique() %>%
  rename(Company = company_name) %>%
  rename(Address = address) %>%
  mutate(key = paste("www.portlandcleanair.org/", key, sep="")) %>% 
  rename('More Info URL' = key) %>% 
  mutate(in_deq = ifelse(!is.na(in_deq), "Yes", "No")) %>% 
  rename("Has DEQ Permit" = in_deq) %>%
  mutate(in_storage = ifelse(!is.na(in_storage), "Yes", "No")) %>% 
  rename("Has Onsite Storage of Chemicals" = in_storage) %>%
  mutate(general_type_permit_deq = as.numeric(gsub(",.*","",general_type_permit_deq))) %>%
  filter(!is.na(general_type_permit_deq)) %>%
  rename("DEQ General Permit Type" = general_type_permit_deq) -> tmp_deq_and_onsite

tmp_deq_and_onsite %>%
  filter(`Has DEQ Permit` == "Yes") %>%
  group_by(`DEQ General Permit Type`) %>%
  count() %>%
  arrange(desc(n)) %>% ungroup() %>%
  top_n(10) -> top_permit_categories

tmp_deq_and_onsite %>%
  filter(`Has DEQ Permit` == "Yes") %>%
  left_join(., top_permit_categories, by = c("DEQ General Permit Type" = "DEQ General Permit Type")) %>% 
  mutate(n = ifelse(is.na(n), "Other", as.character(`DEQ General Permit Type`))) %>% 
  rename(`DEQ General Permit Display Type` = n) %>%
  write.csv(., "cleaned_data/map_data/deq_permits.csv", 
            row.names = F)

tmp_deq_and_onsite %>%
  filter(`Has DEQ Permit` == "No") %>%
  write.csv(., "cleaned_data/map_data/onsite_storage.csv", 
            row.names = F)

#####
# geocode the washington county no permit polluters data
# if it's already been done, the if statement skips this step
##### 
if(!file.exists("cleaned_data/map_data/wash_co_no_permit_polluters.csv")) {
  wash_co_no_permit_polluters %>%
    mutate(lat = NA) %>%
    mutate(lng = NA) %>%
    unique() -> wash_co_no_permit_polluters
  
  for(i in 1:nrow(wash_co_no_permit_polluters)) {
    result <- geocode(wash_co_no_permit_polluters$address[i], output = "latlon", source = "dsk")
    wash_co_no_permit_polluters$lng[i] <- as.numeric(result[1])
    wash_co_no_permit_polluters$lat[i] <- as.numeric(result[2])
    
  }
  write.csv(wash_co_no_permit_polluters, "cleaned_data/map_data/wash_co_no_permit_polluters.csv", 
            row.names = F)
} else {
  wash_co_no_permit_polluters <- read.csv("cleaned_data/map_data/wash_co_no_permit_polluters.csv",
                                     stringsAsFactors = F)
}
View(wash_co_no_permit_polluters)
#####
# Write airports and railyards to the same directory
#####
railyards %>%
  rename(Railyard = site_name_railyard) %>%
  rename(Latitude = lat) %>%
  rename(Longitude = lng) %>%
  select(Railyard, Latitude, Longitude) %>%
  write.csv(., "cleaned_data/map_data/railyards.csv", row.names = F)
airports %>%
  rename(County = county_airport) %>%
  rename(Latitude = lat) %>%
  rename(Longitude = lng) %>%
  rename(Airport = site_name_airport) %>%
  select(Airport, County, Latitude, Longitude) %>%
  write.csv(., "cleaned_data/map_data/airports.csv", row.names = F)
