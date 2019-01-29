from jinja2 import Environment, FileSystemLoader
import pandas as pd
import string
import os
import re

# delete all previously rendered templates
os.system("rm -fr rendered_websites/*")

# this is for dealing with some funky characters in some of the data. 
# just going to remove them later
printable = set(string.printable)

# load in the cleaned datasets that were cleaned up in R
companies = pd.read_csv('cleaned_data/companies.csv')
companies = companies
deq_summary = pd.read_csv('cleaned_data/deq_summary.csv')
storage_summary = pd.read_csv('cleaned_data/storage_summary.csv')
deq_cao_summary = pd.read_csv('cleaned_data/deq_cao_summary.csv')
deq_cao_summary = deq_cao_summary.fillna("NA")
rail_air_summary = pd.read_csv('cleaned_data/rail_air_summary.csv')

acdp_scans = {}
permit_re_pattern = re.compile("([0-9]{2}\-[0-9]{4})", re.DOTALL)
for root, dirs, files in os.walk("/Users/bb/Downloads/ACDP Standard and Simple/"):
    for file in files:
        if re.search(permit_re_pattern, file):
            acdp_scan_num = re.search(permit_re_pattern, file).group(1)
            if acdp_scan_num in acdp_scans:
                acdp_scans[acdp_scan_num].append(file)
            else:
                acdp_scans[acdp_scan_num] = [file]


# prepping the template environment
file_loader = FileSystemLoader('templates')
env = Environment(loader=file_loader)

# loading the templates
template = env.get_template('template.html')
template_deq = env.get_template('template_deq.html')
template_storage = env.get_template('template_storage.html')
template_deq_cao = env.get_template('template_deq_cao.html')
template_rail_air = env.get_template('template_rail_air.html')

# make blank tmp files
tmp_deq_cao_template = ""
tmp_deq_template = ""
tmp_storage_template = ""
tmp_rail_air_template = ""

# loop through the company data and pull in other data when relevant.
for index, row in companies.iterrows():
    print row['key']
    print row

    # check if there is relevant DEQ data
    if row['in_deq'] == 1:
        tmp_deq = deq_summary[deq_summary['key'] == row['key']]
        if row['key'] in acdp_scans:
            permit_info = acdp_scans[row['key']]
            permit_info.sort(key=len)
        else:
            permit_info = ''
        tmp_deq_template = template_deq.render(
            company_name_deq = tmp_deq['company_name_deq'].item(),
            naics_code_deq = tmp_deq['naics_code_deq'].item(),
            general_type_permit_deq = tmp_deq['general_type_permit_deq'].item(),
            general_type_desc_permit_deq = tmp_deq['general_type_desc_permit_deq'].item(),
            permit_info = permit_info,
            )
    if row['in_deq_cao'] == 1:
        tmp_deq_cao = deq_cao_summary[deq_cao_summary['key'] == row['key']].drop(columns = ['key'])
        tmp_deq_cao_template = template_deq_cao.render(
            unfiltered_emissions = tmp_deq_cao.to_html(index = False, classes = 'table'),
            )
    if row['in_storage'] == 1:
        tmp_storage = storage_summary[storage_summary['key'] == row['key']]
        company_name_storage = filter(lambda x: x in printable, tmp_storage['company_name_storage'].iloc[0])
        company_type_storage = tmp_storage['company_type_storage'].iloc[0]
        naics_code_storate = tmp_storage['naics_code_storage'].iloc[0]
        naics_description_storage = tmp_storage['naics_code_description_storage'].iloc[0]
        tmp_storage = tmp_storage[['chemical_name_storage', 'hazardous_ingredient_storage',
            'average_amount_storage','maximum_amount_storage',
            'storage_method_storage','hazardous_class_description_storage',
        ]]
        tmp_storage = tmp_storage.rename(columns = lambda x : str(x)[:-8].replace("_", " ").title())
        tmp_storage_template = template_storage.render(
            storage = tmp_storage.to_html(index = False, classes = 'table'), 
            company_name_storage = company_name_storage,
            company_type_storage = company_type_storage,
            naics_code_storate = naics_code_storate,
            naics_description_storage = naics_description_storage,)
    if row['in_rail_air'] == 1:
        tmp_rail_air = rail_air_summary[rail_air_summary['key'] == row['key']].drop(columns = ['key'])
        tmp_rail_air_template = template_rail_air.render(
            rail_air_emissions = tmp_rail_air.to_html(index = False, classes = 'table'),
            )

    rendered_website = template.render(
        company_name = filter(lambda x: x in printable, row['company_name']),
        address = row['address'],
        in_deq = row['in_deq'],
        in_storage = row['in_storage'], 
        in_deq_cao = row['in_deq_cao'],
        in_rail_air =  row['in_rail_air'],
        deq_template = tmp_deq_template,
        storage_template = tmp_storage_template,
        deq_cao_template = tmp_deq_cao_template,
        rail_air_template = tmp_rail_air_template,
        )
    tmp_dir = 'rendered_websites/' + row['key']
    if not(os.path.isdir(tmp_dir)):
        os.mkdir(tmp_dir)
    with open(tmp_dir + '/index.html', 'w') as f:
        f.write(rendered_website)

