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
tmp <- read.csv("raw_data/joined-filtered.tab", sep = "\t", stringsAsFactors = F)
onsite_chem_storage_raw <- read.csv("raw_data/joined.tab", 
                                    sep = "\t", 
                                    quote = "",
                                    stringsAsFactors = F)
# toss first row since there are 2 rows of headers in the file
onsite_chem_storage_raw <- onsite_chem_storage_raw[2:dim(onsite_chem_storage_raw)[1],]

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

# remove all storage facilities who start with 4
onsite_chem_storage_raw %>%
  filter(!grepl("^4.*", NAICS1 )) -> onsite_chem_storage_raw

# only keep the relevant chemical storage data
# so it is more manageable
onsite_chem_storage_raw %>%
  select(FacilityID, FacilityName, BusinessType, 
         NAICS1, NAICSDesc1, NAICS2, NAICSDesc2, 
         ChemicalID, ChemName, HazardousIngredient, 
         AvgAmt, MaxAmt, UnitDesc, StorageType1, 
         HazClass1Desc, HazClass2Desc, Latitude, Longitude, 
         address, County) %>%
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

onsite_chem_storage_trim <- onsite_chem_storage_trim[onsite_chem_storage_trim$County %in% c("CLACKAMAS","MULTNOMAH","WASHINGTON"),]

######
# Data set 2 - Remove all non-hazardous storage
######

# remove list of chemicals 
onsite_chems_to_be_removed <- read.xlsx("raw_data/edit list HSIS.xlsx", colNames = F)
onsite_chems_to_be_removed2 <- read.xlsx("raw_data/original list.xlsx", colNames = F)
onsite_chems_to_be_removed2$X1 <- toupper(onsite_chems_to_be_removed2$X1)
onsite_chems_to_be_removed3 <- data.frame(X1 = c("WHEAT", "PLASTER OF PARIS", "CLAY", "IRON", "GLUCOSE", "CORN OIL", "CITRIC ACID"), stringsAsFactors = F)
onsite_chems_to_be_removed4 <- data.frame(X1 = c("AIR", "ALFALFA MEAL", "CELLULOSE FIBER", "CASEIN", "CORN STARCH", "DEXTROSE", "DIESEL FUEL", "DIESEL FUEL 2", "DIESEL FUEL NO 2", "GRAIN DUST", "HYDROGEN", "NO 2 DIESEL", "PUMICE", "SALMON OIL", "SAND", "WHOLE WHEAT FLOUR", "WOOD"), stringsAsFactors = F)
onsite_chems_to_be_removed_all <- bind_rows(onsite_chems_to_be_removed, onsite_chems_to_be_removed2, onsite_chems_to_be_removed3, onsite_chems_to_be_removed4)
onsite_chems_to_be_removed_all$remove <- 1

onsite_chems_to_be_removed_all %>% arrange(X1) -> onsite_chems_to_be_removed_all
write.csv(onsite_chems_to_be_removed_all, "~/Desktop/all_chems_removed.csv")

onsite_chem_storage_trim %>%
  left_join(., onsite_chems_to_be_removed_all, by = c("hazardous_ingredient_storage" = "X1")) %>%
  left_join(., onsite_chems_to_be_removed_all, by = c("chemical_name_storage" = "X1")) %>%
  filter(is.na(remove.x)) %>%
  filter(is.na(remove.y)) %>%
  select(-starts_with("remove")) -> onsite_chem_storage_trim

# remove ad hoc list of chemicals
onsite_chem_storage_trim %>%
  filter(!grepl("HYDROCARBON", paste(hazardous_ingredient_storage, chemical_name_storage))) %>%
  filter(!grepl("PETROLEUM", paste(hazardous_ingredient_storage, chemical_name_storage))) %>%
  filter(!grepl("BATTERIES", paste(hazardous_ingredient_storage, chemical_name_storage))) %>%
  filter(!grepl("WIRELESS COMMUNICATIONS", company_type_storage)) -> onsite_chem_storage_trim

# files referenced for posterity
# write.csv(onsite_chem_storage_trim, file = "~/Desktop/onsite_storage_filtered_mult_clack_wash_co.csv")
# write.xlsx(onsite_chem_storage_trim, "~/Desktop/joined.filtered2.xlsx")

#######
# Data Set 3 - Multnomah County DEQ Permits
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
deq_permits_mult_co$county <- "Multnomah"

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
deq_permits_wash_co$county <- "Washington"

# combine Washco and Multco deq datasets into one dataset.
deq_permits_wash_co$Operating.Status <- NA
names(deq_permits_wash_co)[names(deq_permits_wash_co) == "X7"] <- 'X8'
deq_permits <- rbind(deq_permits_mult_co, deq_permits_wash_co)


#####
# Data Set 4 - Clackamas County DEQ Permits
#####
deq_permits_clack_co <- read.csv("raw_data/clackamas_acdp.csv", stringsAsFactors = F)

# this dataset has alpha codes for permits so map them to the numeric values
alpha_permit_codes <- c("G", "ST", "SI", "BS", "TV")
numeric_permit_codes <- c(31, 32, 33, 34, 31)
codes <- data.frame(alpha_permit_codes, numeric_permit_codes, stringsAsFactors = F)
deq_permits_clack_co %>%
  left_join(., codes, by = c("Permit_Type" = "alpha_permit_codes")) %>%
  mutate(county = "Clackamas") -> deq_permits_clack_co
paste(
  deq_permits_clack_co$Site_Address,
  deq_permits_clack_co$City,
  sep = ", "
) %>% sub("-[0-9]{4}","",.) -> deq_permits_clack_co$address

deq_permits_clack_co %>%
  mutate(tmp_codes = substring(Permit_Number,9, 10)) %>%
  mutate(numeric_permit_codes = ifelse(Permit_Type == "G", tmp_codes, numeric_permit_codes)) %>%
  mutate(numeric_permit_codes = ifelse(numeric_permit_codes == "R2", "06", numeric_permit_codes)) -> deq_permits_clack_co

# get Clackamas County to match the merged dataset
deq_permits_clack_co %>% 
  mutate(`DEQ.Permit.and.Review` = paste("www.portlandcleanair.org/", Source_Number, sep="")) %>%
  select(Source_Number, Source_Name, Site_Address, City, Operating_Status, 
         SIC_Codes, NAICS_Codes, numeric_permit_codes, Permit_Number, `DEQ.Permit.and.Review`, 
         address, county) %>%
  rename(`Source.Number` = Source_Number) %>%
  rename(`Source.Name` = Source_Name) %>%
  rename(`Site.Address` = Site_Address) %>%
  rename(`City,.State.Zip` = City) %>%
  rename(`Operating.Status` = Operating_Status) %>%
  rename(`SIC.Codes` = SIC_Codes) %>%
  rename(`NAICS.Codes` = NAICS_Codes) %>%
  rename(X8 = numeric_permit_codes) %>%
  rename(`Permit.Number` = Permit_Number) -> deq_permits_clack_co


# combine clackamas with the other data sets and remove all data that doesn't have a permit number.
rbind(deq_permits, deq_permits_clack_co) -> deq_permits
deq_permits %>%
  filter(!is.na(Permit.Number)) -> deq_permits
deq_permits$in_deq_permits <- 1


#####
# Data Set 5 - Permit Type Descriptions
#####
deq_permit_desc <- read.csv("raw_data/permit_types.csv", 
                            stringsAsFactors = F)
deq_permit_desc$general_type_permit_deq <- as.character(deq_permit_desc$general_type_permit_deq)

# rename the columns to make more sense
# and join in the descriptions of the permit types
deq_permits %>%
  rename(source_number_deq = Source.Number) %>%
  rename(company_name_deq = Source.Name) %>%
  rename(naics_code_deq = NAICS.Codes) %>%
  rename(permit_number_deq = Permit.Number) %>%
  rename(general_type_permit_deq = X8) %>%
  rename(pca_website = DEQ.Permit.and.Review) %>%
  rename(in_deq = in_deq_permits) %>%
  select(ends_with("deq"), address, pca_website) %>%
  left_join(., deq_permit_desc, 
            by = c("general_type_permit_deq" = "general_type_permit_deq")) %>%
  mutate(general_type_desc_permit_deq = coalesce(general_type_desc_permit_deq, "Other")) -> deq_permits 


# filter out coffee shops
# TODO filter out gas stations somehow
deq_permits %>%
  filter(general_type_permit_deq != 16) %>% ## 16 is coffee roasters
  filter(!grepl("brew", company_name_deq, ignore.case = T)) %>% # remove places named brew something
  filter(!grepl("coffee", company_name_deq, ignore.case = T)) -> deq_permits # remove places named coffee something

#####
# Data Set 6 - Railyards
#####
railyards <- read.xlsx("raw_data/NEI PCA railyards.xlsx")
railyards %>%
  rename(site_name_railyard = facility_site_name) %>%
  rename(lat = latitude_msr) %>%
  rename(lng = longitude_msr) %>%
  mutate(in_railyard = 1) %>%
  select(ends_with("railyard"), lat, lng) -> railyards

#####
# Data Set 7 - Airports
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
# Data Set 8 - Washington County No Permit Polluters
#####
#### TODO ADD DRYCLEANERS AND REMOVE THIS
#wash_co_no_permit_polluters <- read.xlsx("raw_data/wash county no permit polluters.xlsx")
#wash_co_no_permit_polluters %>%
#  mutate(StZip = substr(StZip, 1, 5)) %>%
#  mutate(address = paste(LocAddress, ", ", City, ", OR ", StZip, sep = "")) %>%
#  mutate(in_wash_co_no_permit = 1) %>%
#  rename(site_name_wash_co_no_permit = FacilityName) %>%
#  select(ends_with("no_permit"), address) -> wash_co_no_permit_polluters


#####
# Combine DEQ Permits and Onsite Storage Data
# These are combined because they have more info that can go on individual websites.
#####
# first we'll geo-code all addresses so we can match on lat/lng and ignore any address formatting issues
# this data set was generated from geocoding_addresses.R
addresses <- read.csv("cleaned_data/addresses.csv", stringsAsFactors = F)

# create one consolidated dataset with deq permits and onsite storage
# we'll create an arbitrary key rather than use the DEQ permit for the key.
deq_permits <- left_join(deq_permits, addresses, by = c("address" = "address"))
onsite_chem_storage_trim %>% 
  select(-lat, -lng) -> onsite_chem_storage_trim
onsite_chem_storage_trim <- left_join(onsite_chem_storage_trim, addresses, by = c("address" = "address"))

#full_join(deq_permits, onsite_chem_storage_trim, by = "address") %>%
#  mutate(address_id = group_indices(.,address)) %>%
#  mutate(key = coalesce(source_number_deq, paste('onsite_storage_',company_id_storage, sep=""))) -> full_ds

full_join(deq_permits, onsite_chem_storage_trim, by = c("lat" = "lat", "lon" = "lon")) %>%
  mutate(address = coalesce(clean_address.x, clean_address.y, address.x, address.y)) %>%
  select(-address.x, -address.y, -clean_address.x, -clean_address.y) %>%
  mutate(address_id = group_indices(.,address)) %>%
  mutate(key = coalesce(source_number_deq, paste('onsite_storage_',company_id_storage, sep=""))) -> full_ds

full_ds %>%
  select(source_number_deq, company_name_deq, naics_code_deq, 
         permit_number_deq, general_type_permit_deq, general_type_desc_permit_deq, 
         pca_website, address, lat, lon, in_deq, company_name_storage, 
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
  select(company_name, address, key, in_deq, in_storage, 
         general_type_permit_deq, general_type_desc_permit_deq) %>%
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
  rename("DEQ General Permit Type" = general_type_permit_deq) %>%
  rename("DEQ General Permit Type Description" = general_type_desc_permit_deq) -> tmp_deq_and_onsite

tmp_deq_and_onsite %>%
  filter(`Has DEQ Permit` == "Yes") %>%
  filter(grepl("^1", `DEQ General Permit Type`)) %>%
  write.csv(., "cleaned_data/map_data/deq_permits_pt1.csv", 
            row.names = F)

tmp_deq_and_onsite %>%
  filter(`Has DEQ Permit` == "Yes") %>%
  filter(!grepl("^1", `DEQ General Permit Type`)) %>%
  write.csv(., "cleaned_data/map_data/deq_permits_pt2.csv", 
            row.names = F)

tmp_deq_and_onsite %>%
  filter(`Has DEQ Permit` == "No") %>%
  select(Company, Address, `More Info URL`) %>%
  write.csv(., "cleaned_data/map_data/onsite_storage.csv", 
            row.names = F)

#####
# Write airports, railyards, and Wash Co No Permit Polluters to the same map directory
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
#wash_co_no_permit_polluters %>%
#  rename("Site Name" = site_name_wash_co_no_permit) %>%
#  rename(Address = address) %>%
#  select(`Site Name`, Address) %>%
#  write.csv(.,"cleaned_data/map_data/wash_co_no_permit_polluters.csv", row.names = F )
