# portland_clean_air

This is the script for cleaning up emissions data in Portland and doing some basic analysis.


### Prerequisites
Must have Python and R set up. For R, you'll need the 'stringr' and 'dplyr' library.

### Process
1) The `clean_csv.py` takes the `2016_deq_emission.csv` and fixes issues with bad line breaks, commas in names.
2) The `join_data_sets.R` joins all the data together and does some basic analysis.

### TODOs:
[ ] The `NEW 2016_deq_cas_data_descriptors.csv` file looks like it was opened and saved in Excel at one point. Fields like `03-1794` are now saved as `Mar-17` and the preceise data is gone. If we could find a version of the data without excel saving that would be great.
[ ] When the same data exists for multiple sites, how do we know which is real and which is maybe just an office or something?
[ ] data_a column is messy still. We're dropping 2046 rows of 37k.
