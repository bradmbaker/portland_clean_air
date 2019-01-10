library(dplyr)
library(tidyr)

#####
# Step 0 - Read in Data
#####
setwd("~/Desktop/Portland_Clean_Air/deq_emissions/")

co_details <- read.csv("prejoined_data//2016_co_details.tsv", sep="\t",
                     stringsAsFactors = F,
                     header = F,
                     quote = "",
                     col.names = c("company_source_no",
                                   "addr_hash_pt1",
                                   "addr_hash_pt2",
                                   "addr_hash_pt3",
                                   "addr_hash_pt4",
                                   "addr_hash_pt5",
                                   "emi_hash_pt1",
                                   "emi_hash_pt2",
                                   "mat_hash_pt1",
                                   "mat_hash_pt2"))


emi_agg <- read.csv("prejoined_data/2016_emi_agg.tsv", sep = "\t", fill = T,
                    header = F,
                    stringsAsFactors = F,
                    col.names = c("row_id", "units_id", 
                                  "emi_agg_amt_1", "emi_agg_unit_1", "emi_agg_unit_1_desc",
                                  "emi_agg_amt_2", "emi_agg_unit_2", "emi_agg_unit_2_desc", 
                                  "emi_agg_unclear_a", "emi_agg_unclear_b"))
emi_agg$row_id <- as.integer(emi_agg$row_id)

mat_agg <- read.csv("prejoined_data/2016_mat_agg.tsv", sep = "\t", fill = T,
                    header = F, 
                    stringsAsFactors = F,
                    col.names = c("row_id", "units_id", 
                                 "mat_agg_1", "mat_agg_2", "mat_agg_3",
                                 "mat_agg_4", "mat_agg_5", "mat_agg_6",
                                 "mat_agg_7", "mat_agg_8", "mat_agg_9"))

emi_desc <- read.csv("prejoined_data/2016_emi_desc.tsv", sep = "\t", fill = T, 
                     quote = "", 
                     header = F, 
                     stringsAsFactors = F,
                     col.names = c("row_id", "units_id", 
                                   "desc_col_1", "desc_col_2", "desc_col_3"))

mat_desc <- read.csv("prejoined_data/2016_mat_desc.tsv", sep = "\t", fill = T,
                     header = F,
                     stringsAsFactors = F,
                     col.names = c("row_id", "units_id",
                                   "desc_col_1", "desc_col_2", "desc_col_3", "desc_col_4"))


emi_chem <- unique(read.csv("raw_data/2016_emi_chem.tsv", sep = "\t", header = F, stringsAsFactors = F))
mat_chem <- read.csv("raw_data/2016_mat_chem.tsv", sep = "\t", header = F, stringsAsFactors = F)
row_lookup <- read.csv("raw_data/2016_row_lookup.tsv", 
                       sep = "\t", 
                       header = F, 
                       quote = "", 
                       stringsAsFactors = F,
                       col.names = c("row_id", "other_row_id", "chem_id_array", "sheet_key", "co_sourc_no", "file_name"))
units <- read.csv("raw_data/2016_units.tsv", sep = "\t", header = F, stringsAsFactors = F, 
                  col.names = c("units_id", "col_headers", "last_descriptor_column"))

######
# Step 1 - Get all companies with an EMI data
######
co_details %>%
  mutate(address = paste(addr_hash_pt3, addr_hash_pt4, addr_hash_pt5, sep = ", ")) %>%
  filter(emi_hash_pt1 == "true")-> co_details_emi

#####
# Step 2 - Pull In Row Info
#####
#clean up row lookup table from having array to having a column
row_lookup %>%
  separate_rows(., chem_id_array, sep = ",") %>%
  mutate(chem_id_array = gsub('\\"|\\[|\\]', '',chem_id_array)) %>%
  mutate(chem_id_array = trimws(chem_id_array)) -> row_lookup

left_join(co_details_emi, row_lookup, by = c("company_source_no" = "co_sourc_no")) -> co_details_emi

#####
# Step 3 - Pull in All Data
#####
left_join(co_details_emi, emi_desc, by = c("row_id" = "row_id")) -> co_details_emi
left_join(co_details_emi, emi_agg, by = c("row_id" = "row_id")) -> co_details_emi
left_join(co_details_emi, emi_chem, by = c("chem_id_array" = "V1")) -> co_details_emi
left_join(co_details_emi, units, by = c("units_id.x" = "units_id")) -> co_details_emi

#####
# Step 4 - Remove all process with a filter
##### 




View(co_details_emi)
str(units)
str(emi_chem)            
            #co_details_emi %>%
  left_join(., emi_agg, by = c("" = ""))
View(row_lookup)

View(tmp)  
mutate(read.table(text = addr_hash2, sep = ",", as.is = TRUE, check.names = FALSE))


  

co_details %>% 
  mutate(addr1 = str_match(addr_hash, "( [0-9]+.*)]]")[,2]) %>%
  mutate(addr2 = str_match(addr_hash, "( PO B.*)]]")[,2]) %>% View()

View(str_match(co_details$addr_hash, "( [0-9]+.*)"))
View(grep("( [0-9]+.*)","\\1", co_details$addr_hash, value = T))
  mutate(address = grep(" [0-9]+.*", addr_hash, value = T))
%>% head(., n=100) %>% View()
View(co_details[co_details$company_source_no == "26-3135",])




# company bullseye glass
co_details[co_details$company_source_no == "26-3135",]

# all chemicals associated with bulleye
row_lookup[row_lookup$co_sourc_no == "26-3135",] %>%
  separate_rows(., chem_id_array, sep = ",") %>%
  mutate(chem_id_array = gsub('\\"|\\[|\\]', '',chem_id_array)) %>%
  mutate(chem_id_array = trimws(chem_id_array)) -> tmp_rows
# all chemicals associated with bullseye
emi_chem %>%
  filter(V1 %in% tmp_rows$chem_id_array) -> tmp_chems
View(tmp_chems)


View(head(emi_desc[emi_desc$row_id == "04116",]))
View(((emi_agg[emi_agg$row_id == "04116",])))
emi_agg %>%
  filter(row_id == "04116") %>% View()

emi_agg %>%
  filter(units_id == 5069) %>% dim()
mat_agg %>%
  filter(units_id == 921) %>% dim()


View(emi_agg)
View(units)

# how does one look into agg
View(head(emi_agg))
left_join(tmp_rows, tmp2, by = c("chem_id_array" = "V1")) %>% View

View(head(emi_chem ))
032783

rows <- row_lookup[row_lookup$co_sourc_no == "26-3135",]$row_id

View(unique(emi_chem[emi_chem$V1 %in% rows,]))
emi_chem %>% filter(V4 == "Antimony") %>% head()

row_lookup[row_lookup$row_id == 04006,]
emi_chem[emi_chem$V1=="4089",]


emi_agg[emi_agg$row_id == "04006",] #not here
emi_chem[emi_chem$V1 == "4006",] # not here
emi_desc[emi_desc$row_id == "04006",]
