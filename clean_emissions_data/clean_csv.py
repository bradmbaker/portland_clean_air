# this script reads in data and replaces a csv with a quoted csv
import re

# doing some file level edits here
# there are some weird line breaks in some cas_name fields so replacing those
# some lines lead with a comma
f = open('/Users/bb/Desktop/Portland_Clean_Air/2016_deq_emission.csv', 'r')
f_out = open('/Users/bb/Desktop/Portland_Clean_Air/2016_deq_emission_pre_clean.csv', 'w')
data = f.read()
f_out.write(re.sub("\n,","\n", # remove leading commas
    re.sub("\n\(","(",data) # fix cas_names
    ))
f.close()
f_out.close()



f = open('/Users/bb/Desktop/Portland_Clean_Air/2016_deq_emission_pre_clean.csv', 'r')
# f = open('/Users/bb/Desktop/Portland_Clean_Air/tmp.csv', 'r')
f_out = open('/Users/bb/Desktop/Portland_Clean_Air/2016_deq_emission_clean.csv', 'w')

# write the first field into the new file as quote separated
firstline = f.readline()
# coSourceNo,desc_row_id,excel_col_dec,excel_col_alpha,cas_code,
# cas_name,
# unit_a,data_a,unit_b,data_b,unit_c,data_c

firstline = firstline.rstrip().split(',')
firstline = ', '.join('"{0}"'.format(field) for field in firstline) 
f_out.write(firstline + "\n")


field_patterns = [
 "[0-9\-]+",     # coSourceNo
 "[0-9]+",       # desc_row_id
 "[0-9]+",       # excel_col_dec
 "[A-Z]+",       # excel_col_alpha
 "[0-9\-]+",     # cas_code
]

# we deal with cas_name separately


for line in f:
    # deal with the first few regular fields first
    tmp_row = ""
    for pattern in field_patterns:
        tmp_match = re.search(pattern, line).group(0)
        line = line.replace(tmp_match + ',', "", 1)
        tmp_row = tmp_row + '"' + tmp_match + '", '
    
    # next deal with the gross field cas_name
    tmp_match = re.search("(.*),ef \(lb", line).group(1) # cas_name
    line = line.replace(tmp_match + ',', "", 1)
    tmp_row = tmp_row + '"' + tmp_match + '", '


    # deal with the rest of the columns 
    # some of the rows are all blank so the try/except just keeps em blank and lets it run
    try:
        line = line.rstrip().split(',')
        line = ', '.join('"{0}"'.format(field) for field in line) 
    except:
        line = '"","","","","","",""'
    tmp_row = tmp_row + line
    # tmp_row
    f_out.write(tmp_row + "\n")


f.close()
f_out.close()


#desc_row_id = re.search("[0-9]+", line).group(0)
#line = line.replace(desc_row_id + ',', "", 1)
