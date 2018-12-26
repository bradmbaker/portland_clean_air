import re

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



# first clean 2016_emi_agg data
f = open('/Users/bb/Desktop/Portland_Clean_Air/deq_emissions/raw_data/2016_emi_agg.tsv', 'r')
f_out = open('/Users/bb/Desktop/Portland_Clean_Air/deq_emissions/prejoined_data/2016_emi_agg.tsv', 'w')

# we just need to move the units_ID column from being the last in an arbitrary list
# to the second position
for line in f:
    tmp_line = re.sub('\n', '', line)
    tmp_line = tmp_line.split("\t")
    new_seq = [0, len(tmp_line)-1] + range(1, len(tmp_line)-1)
    cleaned_line = [ tmp_line[i] for i in new_seq]
    f_out.write("\t".join(cleaned_line) + "\n")

# first clean 2016_mat_agg data
f = open('/Users/bb/Desktop/Portland_Clean_Air/deq_emissions/raw_data/2016_mat_agg.tsv', 'r')
f_out = open('/Users/bb/Desktop/Portland_Clean_Air/deq_emissions/prejoined_data/2016_mat_agg.tsv', 'w')

# we just need to move the units_ID column from being the last in an arbitrary list
# to the second position
for line in f:
    tmp_line = re.sub('\n', '', line)
    tmp_line = tmp_line.split("\t")
    new_seq = [0, len(tmp_line)-1] + range(1, len(tmp_line)-1)
    cleaned_line = [ tmp_line[i] for i in new_seq]
    f_out.write("\t".join(cleaned_line) + "\n")

