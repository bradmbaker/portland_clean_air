setwd("~/Desktop/Portland_Clean_Air/deq_emissions/")

co_details <- read.csv("raw_data/2016_co_details.tsv", sep="\t",
                       col.names = c("company_source_no",
                                     "addr_hash",
                                     "emi_hash",
                                     "mat_hash"))


emi_agg <- read.csv("prejoined_data/2016_emi_agg.tsv", sep = "\t", fill = T,
                    header = F,
                    col.names = c("row_id", "units_id", 
                                  "emi_amt_1", "emi_unit_1", "emi_unit_1_desc",
                                  "emi_amt_2", "emi_unit_2", "emi_unit_2_desc", 
                                  "unclear_a", "unclear_b"))

mat_agg <- read.csv("prejoined_data/2016_mat_agg.tsv", sep = "\t", fill = T,
                    header = F, 
                    col.names = c("row_id", "units_id", 
                                 "agg_1", "agg_2", "agg_3",
                                 "agg_4", "agg_5", "agg_6",
                                 "agg_7", "agg_8", "agg_9"))

emi_desc <- read.csv("prejoined_data/2016_emi_desc.tsv", sep = "\t", fill = T, 
                     header = F, 
                     col.names = c("row_id", "units_id", 
                                   "desc_col_1", "desc_col_2", "desc_col_3"))

mat_desc <- read.csv("prejoined_data/2016_mat_desc.tsv", sep = "\t", fill = T,
                     header = F,
                     col.names = c("row_id", "units_id",
                                   "desc_col_1", "desc_col_2", "desc_col_3", "desc_col_4"))


emi_chem <- read.csv("raw_data/2016_emi_chem.tsv")
mat_chem <- read.csv("raw_data/2016_mat_chem.tsv")
row_lookup <- read.csv("raw_data/2016_row_lookup.tsv")
units <- read.csv("raw_data/2016_units.tsv")

