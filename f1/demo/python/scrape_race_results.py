import time
import json

from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager

url = 'https://www.formula1.com/'

# Headless Browser
options = Options()
options.add_argument("--headless=new")
options.add_argument('window-size=1920x1080')
driver = webdriver.Chrome(service=ChromeService(
    ChromeDriverManager().install()), options=options)

# Launch Browser
# options = Options()
# options.add_argument("--disable-notifications")
# driver = webdriver.Chrome(service=ChromeService(
#     ChromeDriverManager().install()))
# driver.maximize_window()

driver.get(url)

results_years_links = []
results_years_link_item = {}

results_years_data = []
results_year_data_item = {}

try:
    print('\nOn F1 Home Page.')
    print('Finding iFrames...')
    divs = driver.find_elements(By.ID, 'sp_message_container_1149951')
    print('Deleting iFrames...')
    for indx, div in enumerate(divs):
        str = 'return document.getElementById("sp_message_container_1149951").remove();'
        driver.execute_script(str)
    print('\nSwitching to default page content...')
    driver._switch_to.default_content()

    print('\nGetting Primary Links...')
    primary_links = driver.find_element(By.CLASS_NAME, 'primary-links')
    primary_link_list = primary_links.find_element(By.TAG_NAME, 'ul')
    primary_link_items = primary_link_list.find_elements(By.TAG_NAME, 'li')
    results_item = primary_link_items[4]
    results_link = results_item.find_element(By.TAG_NAME, 'a')
    print('Hover over Results link...')
    results_hover = ActionChains(driver).move_to_element(results_link)
    results_hover.perform()

    print('\nFind Results Archive Link...')
    nav_header = results_item.find_element(By.CSS_SELECTOR, 'div[class="nav-header"]')
    results_anchors = nav_header.find_elements(By.TAG_NAME, 'a')
    archive_link = results_anchors[3]
    archive_hover = ActionChains(driver).move_to_element(archive_link)
    archive_hover.perform()

    print('Navigating to Results Archive page...')
    archive_link.click()

    print('\nOn Results Archive page...')
    print('Getting Archive year links...')

    resultsarchive_filter = driver.find_element(By.CLASS_NAME, 'resultsarchive-filter-container')
    resultsarchive_filter_divs = resultsarchive_filter.find_elements(By.CSS_SELECTOR, 'div[class="resultsarchive-filter-wrap"]')
    results_years = resultsarchive_filter_divs[0]
    results_year_ahchors = results_years.find_elements(By.TAG_NAME, 'a')
    
    for results_year_ahchor in results_year_ahchors:
        results_year_ahchor_span = results_year_ahchor.find_element(By.TAG_NAME, 'span')
        results_years_link_item['year'] = results_year_ahchor_span.get_attribute('innerHTML')
        results_years_link_item['link'] = results_year_ahchor.get_attribute('href')
        results_years_links.append(results_years_link_item)
        results_years_link_item = {}

    results_years_links_cpy = results_years_links[:3] # Only process 3 records for demo
    print('\nProcessing results...')
    for results_years_link in results_years_links_cpy:
        driver.get(results_years_link['link'])
        result_title = driver.find_element(By.CLASS_NAME, 'ResultsArchiveTitle').text
        print(f'\tProcessing {result_title}...')

        resultsarchive_table = driver.find_element(By.CSS_SELECTOR, 'table[class="resultsarchive-table"]')
        resultsarchive_table_body = resultsarchive_table.find_element(By.TAG_NAME, 'tbody')
        resultsarchive_table_rows = resultsarchive_table_body.find_elements(By.TAG_NAME, 'tr')

        for resultsarchive_table_row in resultsarchive_table_rows: 
            resultsarchive_table_cells = resultsarchive_table_row.find_elements(By.TAG_NAME, 'td')
            grand_prix_row = resultsarchive_table_cells[1].find_element(By.TAG_NAME, 'a')
            date_row = resultsarchive_table_cells[2]

            winner_row = resultsarchive_table_cells[3]
            winner_row_cells = winner_row.find_elements(By.TAG_NAME, 'span')

            car_row = resultsarchive_table_cells[4]
            laps_row = resultsarchive_table_cells[5]
            time_row = resultsarchive_table_cells[6]

            results_year_data_item['year'] = results_years_link['year']
            results_year_data_item['grand_prix'] = grand_prix_row.text
            results_year_data_item['date'] = date_row.text
            results_year_data_item['winner'] = winner_row_cells[0].text + " " + winner_row_cells[1].text
            results_year_data_item['car'] = car_row.text
            results_year_data_item['laps'] = laps_row.text
            results_year_data_item['time'] = time_row.text
            results_years_data.append(results_year_data_item)
            results_year_data_item = {}

    time.sleep(5)
    # f = open("race_results_data.json", "w")
    # f.write(json.dumps(results_years_data))
    # f.close()

    print(json.dumps(results_years_data))

except Exception as e:
    print('Error:')
    print(e)

print('\nComplete.')
time.sleep(3)
driver.close()
driver.quit()
