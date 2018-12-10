# combining_onsite_storage_and_permits

This directory prepares the data for the map on the homepage of the Portland Clean Air.

### Process
There isn't a unique indentifier across the datasets like a business key or anything, so the basic process is to clean up addresses to be in matching format and join the datasets together by address. There are surely going to be some cases where a match doesn't occur when it should so at some point should go through and verify these. The file that does the cleaning and combining is `clean_and_combine_deq_and_onsite.R`


### Process TODO

Come up with a template for what the output might look like. Script to generate files that go into template.

Also add these points to a google map.

### Raw Files
`joined-filtered.tab` is the onsite storage of chemicals. There is one row per chemical stored onsite. The relevant columns are the location, the business name, NAICS code, and the chemical.

`rptSourcesMultnomahCounty.xlsx` and `rptSourcesWashingtonCounty.xlsx` are DEQ permits. There isn't much data in these spreadsheets, but the relevant info is the the Source Number which is a unique identifier for the business, business name, address, NAICS code, and the Portland Clean Air url. 

### Cleaned Files

`deq_permits_and_onsite_storage.csv` has both DEQ permits and onsite storage data. There is a key column that is the DEQ permit if it exists (to match the old PCA standard) and then the onsite storage facility ID if there is no DEQ permit. 
