require 'scraperwiki'
require 'mechanize'

FileUtils.touch('data.sqlite')

today = Time.now.strftime('%Y-%m-%d')

url   = 'https://www.geelongaustralia.com.au/advertisedplanning/default.aspx'
agent = Mechanize.new
page  = agent.get(url)

table1 = page.search('table.table.table-striped')[0]
table1.search('tr')[0].remove
rows1 = table1.search('tr')
table2 = page.search('table.table.table-striped')[1]
table2.search('tr')[0].remove
rows2 = table2.search('tr')

for row in rows1 do
  record = {}
  suburb = row.search('td')[1].text.strip
  record['address'] = row.search('td')[0].text.strip + ', ' + suburb
  record['council_reference'] = row.search('td')[2].text.strip
  record['date_scraped'] = today
  record['on_notice_from'] = DateTime.strptime(row.search('td')[3].text.strip, '%d %b %Y').strftime('%Y-%m-%d')
  record['on_notice_to'] = DateTime.strptime(row.search('td')[4].text.strip, '%d %b %Y').strftime('%Y-%m-%d')
  link = 'https://www.geelongaustralia.com.au/advertisedplanning/' + row.search('a').to_s.split('"')[1]
  record['info_url'] = link
  page  = agent.get(link)
  record['description'] = page.search('p')[3].text.strip
  ScraperWiki.save_sqlite(['council_reference'], record)
end

for row in rows2 do
  record = {}
  suburb = row.search('td')[1].text.strip
  record['address'] = row.search('td')[0].text.strip + ', ' + suburb
  record['council_reference'] = row.search('td')[2].text.strip
  record['date_scraped'] = today
  record['on_notice_to'] = DateTime.strptime(row.search('td')[3].text.strip, '%d %b %Y').strftime('%Y-%m-%d')
  link = 'https://www.geelongaustralia.com.au/advertisedplanning/' + row.search('a').to_s.split('"')[1]
  record['info_url'] = link
  page  = agent.get(link)
  record['description'] = page.search('p')[3].text.strip
  ScraperWiki.save_sqlite(['council_reference'], record)
end
