import time
import json

from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager

def write_to_file(file_name, data):
    f = open(file_name, "w")
    f.write(json.dumps(data))
    f.close()

def get_archive_years(results_year_anchors):
    results_years_links = []
    results_years_link_item = {}
    for results_year_anchor in results_year_anchors:
        results_years_link_item['year'] = results_year_anchor.get_attribute('innerHTML')
        results_years_link_item['link'] = results_year_anchor.get_attribute('href')
        results_years_links.append(results_years_link_item)
        results_years_link_item = {}
    return results_years_links

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

results_categories_links = []
results_categories_link_item = {}

results_years_links = []
results_years_link_item = {}

results_years_data = []
results_year_data_item = {}

drivers_results_years_data = []
drivers_results_years_data_item = {}

teams_results_years_data = []
teams_results_years_data_item = {}

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
    results_archive_filter = driver.find_element(By.CSS_SELECTOR, 'div[class="f1-container container"]')    
    results_archive_filter_divs_container = results_archive_filter.find_element(By.CSS_SELECTOR, 'div[class="grid max-laptop:gap-xs laptop:grid-cols-3 laptop:divide-x"]')
    results_archive_filter_divs = results_archive_filter_divs_container.find_elements(By.TAG_NAME, 'details')

    print('Getting Result Categories links...')
    results_categories = results_archive_filter_divs[1]
    results_categorie_items = results_categories.find_elements(By.TAG_NAME, 'li')

    for results_categorie_item in results_categorie_items:
        results_categorie_item_anchor = results_categorie_item.find_element(By.TAG_NAME, 'a')

        results_categories_link_item['title'] = results_categorie_item_anchor.text
        results_categories_link_item['link'] = results_categorie_item_anchor.get_attribute('href')
        results_categories_links.append(results_categories_link_item)
        results_categories_link_item = {}
    
    # Strip "Fastest Laps" data
    results_categories_links = results_categories_links[:-1]
    
    for results_categories_link in results_categories_links:
        result_cat_title = results_categories_link['title']
        # Delte the iFrames, again, since on new page
        divs = driver.find_elements(By.ID, 'sp_message_container_1149951')
        for indx, div in enumerate(divs):
            str = 'return document.getElementById("sp_message_container_1149951").remove();'
            driver.execute_script(str)
        driver._switch_to.default_content()

        print(f"\nProcessing {result_cat_title} ...")
        driver.get(results_categories_link['link'])
        driver.refresh()

        print('\tGetting Archive year links...')
        results_archive_filter = driver.find_element(By.CSS_SELECTOR, 'div[class="f1-container container"]')
        results_archive_filter_divs_container = results_archive_filter.find_element(By.CSS_SELECTOR, 'div[class="grid max-laptop:gap-xs laptop:grid-cols-3 laptop:divide-x"]')
        results_archive_filter_divs = results_archive_filter_divs_container.find_elements(By.TAG_NAME, 'details')

        results_years = results_archive_filter_divs[0]
        results_year_anchors = results_years.find_elements(By.TAG_NAME, 'a')
        results_years_links = get_archive_years(results_year_anchors)
        results_years_links_cpy = results_years_links[:3] # Only process 3 records for demo

        match result_cat_title:
            case 'RACES':
                # Start with Races results, then loop through years
                for results_years_link in results_years_links_cpy:
                    driver.get(f'https://www.formula1.com/en/results.html/{results_years_link['year']}/races.html')
                    # result_title = driver.find_element(By.TAG_NAME, 'h1').text
                    # print(f'\tProcessing {result_title}...')

                    results_archive_table = driver.find_element(By.CSS_SELECTOR, 'table[class="f1-table f1-table-with-data w-full"]')
                    results_archive_table_body = results_archive_table.find_element(By.TAG_NAME, 'tbody')
                    results_archive_table_rows = results_archive_table_body.find_elements(By.TAG_NAME, 'tr')

                    for results_archive_table_row in results_archive_table_rows: 
                        results_archive_table_cells = results_archive_table_row.find_elements(By.TAG_NAME, 'td')

                        grand_prix_row = results_archive_table_cells[0]
                        date_row = results_archive_table_cells[1]

                        winner_row_cell = results_archive_table_cells[2]
                        winner_name_content = winner_row_cell.find_elements(By.TAG_NAME, 'span')
                        winner_f_name = winner_name_content[0].get_attribute('innerHTML')
                        winner_l_name = winner_name_content[1].text

                        car_row = results_archive_table_cells[3]
                        laps_row = results_archive_table_cells[4]

                        time_row = results_archive_table_cells[5]
                        time_row_para = time_row.find_element(By.TAG_NAME, 'p')

                        results_year_data_item['year'] = results_years_link['year']
                        results_year_data_item['grand_prix'] = grand_prix_row.text
                        results_year_data_item['date'] = date_row.text
                        results_year_data_item['winner'] = winner_f_name + ' ' + winner_l_name
                        results_year_data_item['car'] = car_row.text
                        results_year_data_item['laps'] = laps_row.text
                        results_year_data_item['time'] = time_row_para.get_attribute('innerHTML')
                        results_years_data.append(results_year_data_item)
                        results_year_data_item = {}

                # time.sleep(5)
                # write_to_file('race_results_data.json', results_years_data)
                print(results_years_data)

            case 'DRIVERS':
                # Then go to Drivers results, then loop through years
                for results_years_link in results_years_links_cpy:
                    driver.get(f'https://www.formula1.com/en/results.html/{results_years_link['year']}/drivers.html')
                    # result_title = driver.find_element(By.TAG_NAME, 'h1').text
                    # print(f'\tProcessing {result_title}...')

                    results_archive_table = driver.find_element(By.CSS_SELECTOR, 'table[class="f1-table f1-table-with-data w-full"]')
                    results_archive_table_body = results_archive_table.find_element(By.TAG_NAME, 'tbody')
                    results_archive_table_rows = results_archive_table_body.find_elements(By.TAG_NAME, 'tr')

                    for results_archive_table_row in results_archive_table_rows: 
                        results_archive_table_cells = results_archive_table_row.find_elements(By.TAG_NAME, 'td')

                        driver_pos = results_archive_table_cells[0]
                        
                        driver_name_cell = results_archive_table_cells[1]
                        driver_name_content = driver_name_cell.find_elements(By.TAG_NAME, 'span')
                        driver_f_name = driver_name_content[0].get_attribute('innerHTML')
                        driver_l_name = driver_name_content[1].text

                        nationality = results_archive_table_cells[2]
                        car_row = results_archive_table_cells[3]
                        pts = results_archive_table_cells[4]

                        drivers_results_years_data_item['year'] = results_years_link['year']
                        drivers_results_years_data_item['driver_pos'] = driver_pos.text
                        drivers_results_years_data_item['driver_name'] = driver_f_name + ' ' + driver_l_name
                        drivers_results_years_data_item['nationality'] = nationality.text
                        drivers_results_years_data_item['car'] = car_row.text
                        drivers_results_years_data_item['pts'] = pts.text
                        drivers_results_years_data.append(drivers_results_years_data_item)
                        drivers_results_years_data_item = {}

                # time.sleep(5)
                # write_to_file('drivers_results_data.json', drivers_results_years_data)
                print(drivers_results_years_data)

            case 'TEAMS':
                # Then go to Teams results, then loop through years
                for results_years_link in results_years_links_cpy:
                    if int(results_years_link['year']) >= 1958:
                        driver.get(f'https://www.formula1.com/en/results.html/{results_years_link['year']}/team.html')
                        # result_title = driver.find_element(By.TAG_NAME, 'h1').text
                        # print(f'\tProcessing {result_title}...')

                    results_archive_table = driver.find_element(By.CSS_SELECTOR, 'table[class="f1-table f1-table-with-data w-full"]')
                    results_archive_table_body = results_archive_table.find_element(By.TAG_NAME, 'tbody')
                    results_archive_table_rows = results_archive_table_body.find_elements(By.TAG_NAME, 'tr')

                    for results_archive_table_row in results_archive_table_rows: 
                        results_archive_table_cells = results_archive_table_row.find_elements(By.TAG_NAME, 'td')

                        team_pos = results_archive_table_cells[0]
                        team_name = results_archive_table_cells[1]
                        pts = results_archive_table_cells[2]

                        teams_results_years_data_item['year'] = results_years_link['year']
                        teams_results_years_data_item['team_name'] = team_name.text
                        teams_results_years_data_item['pts'] = pts.text
                        teams_results_years_data.append(teams_results_years_data_item)
                        teams_results_years_data_item = {}
                
                # time.sleep(5)
                # write_to_file('teams_results_data.json', teams_results_years_data)
                print(teams_results_years_data)

    time.sleep(5)

except Exception as e:
    print('Error:')
    print(e)

print('\nComplete.')
time.sleep(3)
driver.close()
driver.quit()