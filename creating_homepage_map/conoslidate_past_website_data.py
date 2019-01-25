## this file takes the old webpages from the /past_websites_docs folder and puts all the relvant
## info into one pickled dicitonary. We'll load this data in later in the render_templates.py

import re
import os
import pickle

# this is the pattern we'll extract with
html_pattern = re.compile("</h1>(.*)</body>", re.DOTALL)

# we'll dump all the data in this dictionary
data_dict = {}

# loop through all the old web files.
for dirname in os.listdir('raw_data/past_website_docs/'):
    tmp_html_doc = open('raw_data/past_website_docs/' + dirname + '/index.html', 'r').read()
    relevant_info = re.search(html_pattern, tmp_html_doc).group(1)
    data_dict[dirname] = relevant_info

pickle.dump(data_dict, open('cleaned_data/old_website_info.p', 'wb'))

