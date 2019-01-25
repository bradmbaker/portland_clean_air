library(httr)
library(jsonlite)

url_lookup <- "https://maps.googleapis.com"
path <- "/maps/api/geocode/json"
api_key <- ""

addresses <- data.frame(address = unique(c(deq_permits$address, 
                                           onsite_chem_storage_trim$address,
                                           deq_cao$Address)), stringsAsFactors = F)
addresses$lat <- 0
addresses$lon <- 0
addresses$clean_address <- ""
for(i in 1:nrow(addresses)) {
  print(i)
  print(addresses$address[i])
  result <- GET(url = url_lookup, 
                path = path, 
                query = list(address = addresses$address[i],
                             key = api_key))
  result <- fromJSON(rawToChar(result$content))
  if(result$status == "ZERO_RESULTS") {
    addresses$lon[i] <- NA
    addresses$lat[i] <- NA
    addresses$clean_address[i] <- addresses$address[i]
  } else {
    addresses$lon[i] <- result$results$geometry$location$lng
    addresses$lat[i] <- result$results$geometry$location$lat
    addresses$clean_address[i] <- result$results$formatted_address
  }
}

write.csv(addresses, "cleaned_data/addresses.csv", row.names = F)
