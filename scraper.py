import os
os.environ["SCRAPERWIKI_DATABASE_NAME"] = "sqlite:///data.sqlite"

import scraperwiki
import requests
from datetime import datetime
from bs4 import BeautifulSoup

today = datetime.today()

url = 'https://www.geelongaustralia.com.au/advertisedplanning/default.aspx'
r = requests.get(url)
soup = BeautifulSoup(r.content, 'lxml')

rows = soup.find_all('tr')

for row in rows:
    try:
        record = {}
        suburb = row.find_all('td')[1].text
        record['address'] = f'{row.find_all("td")[0].text}, {suburb}'.strip().title()
        record['date_scraped'] = today.strftime("%Y-%m-%d")
        info_url = 'https://www.geelongaustralia.com.au/advertisedplanning/' + \
            str(row.find_all('td')[0]).split('"')[1]
        rr = requests.get(info_url)
        soupp = BeautifulSoup(rr.content, 'lxml')
        record['description'] = soupp.find_all('p')[3].text.strip()
        record['council_reference'] = row.find_all('td')[2].text
        record['info_url'] = info_url
        on_notice_from_raw = row.find_all('td')[3].text
        record['on_notice_from'] = datetime.strptime(
            on_notice_from_raw, '%d %b %Y').strftime("%Y-%m-%d")
        on_notice_to_raw = row.find_all('td')[4].text
        record['on_notice_to'] = datetime.strptime(
            on_notice_to_raw, '%d %b %Y').strftime("%Y-%m-%d")

        scraperwiki.sqlite.save(
            unique_keys=['council_reference'], data=record, table_name="data")
    except:
        continue
