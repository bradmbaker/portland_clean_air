from jinja2 import Environment, FileSystemLoader
import pandas as pd
import string

# this is for dealing with some funky characters in some of the data. 
# just going to remove them later
printable = set(string.printable)

# load in the cleaned datasets that were cleaned up in R
companies = pd.read_csv('cleaned_data/companies.csv')
companies = companies[0:3]
deq_summary = pd.read_csv('cleaned_data/deq_summary.csv')
storage_summary = pd.read_csv('cleaned_data/storage_summary.csv')

# prepping the template environment
file_loader = FileSystemLoader('website')
env = Environment(loader=file_loader)

# loading the templates
template = env.get_template('template2.html')
template_deq = env.get_template('template_deq.html')
template_storage = env.get_template('template_storage.html')

# loop through the company data and pull in other data when relevant.
for index, row in companies.iterrows():
    print row['key']
    if row['in_deq'] == 1:
        tmp_deq = deq_summary[deq_summary['key'] == row['key']]
        tmp_deq_template = template_deq.render(
            company_name_deq = tmp_deq['company_name_deq'].item(),
            naics_code_deq = tmp_deq['naics_code_deq'].item(),
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
    rendered_website = template.render(
        company_name = filter(lambda x: x in printable, row['company_name']),
        address = row['address'],
        in_deq = row['in_deq'],
        in_storage = row['in_storage'], 
        deq_template = tmp_deq_template,
        storage_template = tmp_storage_template,
        )
    with open('rendered_websites/' + row['key'] + '.html', 'w') as f:
        f.write(rendered_website)


