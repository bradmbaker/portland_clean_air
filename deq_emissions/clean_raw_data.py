import re
import ast

def reshuffle_columns(file_name):
    input_file = '/Users/bb/Desktop/Portland_Clean_Air/deq_emissions/raw_data/' + file_name
    output_file = '/Users/bb/Desktop/Portland_Clean_Air/deq_emissions/prejoined_data/' + file_name
    f = open(input_file, 'r')
    f_out = open(output_file, 'w')
    for line in f:
        tmp_line = re.sub('\n', '', line)
        tmp_line = tmp_line.split("\t")
        new_seq = [0, len(tmp_line)-1] + range(1, len(tmp_line)-1)
        cleaned_line = [ tmp_line[i] for i in new_seq]
        f_out.write("\t".join(cleaned_line) + "\n")

# Reshuffle columns so that they go row_id, unit_id, ... instead of row_id, ..., unit_id
reshuffle_columns('2016_emi_agg.tsv')
reshuffle_columns('2016_mat_agg.tsv')
reshuffle_columns('2016_emi_desc.tsv')
reshuffle_columns('2016_mat_desc.tsv')


# let's explode the hash that's in the company data to make it easier to work in R.
f = open('/Users/bb/Desktop/Portland_Clean_Air/deq_emissions/raw_data/2016_co_details.tsv', 'r')
f_out = open('/Users/bb/Desktop/Portland_Clean_Air/deq_emissions/prejoined_data/2016_co_details.tsv', 'w')
for line in f:
    tmp_line = re.sub('\n', '', line)
    tmp_line = tmp_line.split("\t")
    addr_hash = ast.literal_eval(tmp_line[1].replace("nil", '""'))
    emi_hash = ast.literal_eval(tmp_line[2].replace('true','"true"').replace('false','"false"'))
    mat_hash = ast.literal_eval(tmp_line[3].replace('true','"true"').replace('false','"false"'))
    new_hash  = [tmp_line[0], 
    addr_hash[1][0], addr_hash[1][1], addr_hash[1][2], addr_hash[1][3],str(addr_hash[1][4]),
    emi_hash[1][0], emi_hash[1][1],
    mat_hash[1][0], mat_hash[1][1]
    ]
    f_out.write("\t".join(new_hash) + "\n")

