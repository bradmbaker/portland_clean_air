library(httr)
library(jsonlite)

url_lookup <- "https://maps.googleapis.com"
path <- "/maps/api/geocode/json"
api_key <- ""

addresses <- data.frame(address = unique(co_details_emi_unfiltered_only$address), stringsAsFactors = F)
addresses$county <- ""
for(i in 1:nrow(addresses)) {
  print(i)
  print(addresses$address[i])
  result <- GET(url = url_lookup, 
                path = path, 
                query = list(address = addresses$address[i],
                             key = api_key))
  result <- fromJSON(rawToChar(result$content))
  if(result$status == "ZERO_RESULTS") {
    addresses$county[i] <- ""
  } else {
    result$results$address_components[[1]] %>% 
      mutate(types=paste(types, collapes = '')) %>%
      filter(grepl("administrative_area_level_2", types)) %>%
      select(long_name) %>%
      as.character() -> county
    print(county)
    addresses$county[i] <- county
    print(addresses$county[i])
  }
}

write.csv(addresses, "prejoined_data/address_to_country_lookup.csv", row.names = F)
