import json
import datetime
import boto3

from tempfile import mkdtemp
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# S3
s3 = boto3.client('s3')
bucket_name = 'cc-f-one-assets-07-13-24v01'
race_results_file_name = 'race_results_data.json'
driver_results_file_name = 'driver_results_data.json'
team_results_file_name = 'team_results_data.json'

def get_archive_years(results_year_ahchors):
    results_years_links = []
    results_years_link_item = {}
    for results_year_ahchor in results_year_ahchors:
        results_year_ahchor_span = results_year_ahchor.find_element(By.TAG_NAME, 'span')
        results_years_link_item['year'] = results_year_ahchor_span.get_attribute('innerHTML')
        results_years_link_item['link'] = results_year_ahchor.get_attribute('href')
        results_years_links.append(results_years_link_item)
        results_years_link_item = {}
    return results_years_links

def delete_iframes(driver):
    divs = driver.find_elements(By.ID, 'sp_message_container_1149951')
    for indx, div in enumerate(divs):
        str = 'return document.getElementById("sp_message_container_1149951").remove();'
        driver.execute_script(str)
    driver._switch_to.default_content()
    return

def get_results_categories_links(results_archive_filter_divs):
    results_categories_links = []
    results_categories_link_item = {}

    results_categories = results_archive_filter_divs
    results_categorie_items = results_categories.find_elements(By.TAG_NAME, 'li')

    for results_categorie_item in results_categorie_items:
        results_categorie_item_anchor = results_categorie_item.find_element(By.TAG_NAME, 'a')

        results_categories_link_item['title'] = results_categorie_item_anchor.text
        results_categories_link_item['link'] = results_categorie_item_anchor.get_attribute('href')
        results_categories_links.append(results_categories_link_item)
        results_categories_link_item = {}
    
    # Strip "Fastest Laps" data
    results_categories_links = results_categories_links[:-1]
    return results_categories_links

def init_page(driver):
    delete_iframes(driver)

    primary_links = driver.find_element(By.CLASS_NAME, 'primary-links')
    primary_link_list = primary_links.find_element(By.TAG_NAME, 'ul')
    primary_link_items = primary_link_list.find_elements(By.TAG_NAME, 'li')
    results_item = primary_link_items[4]
    results_link = results_item.find_element(By.TAG_NAME, 'a')

    results_hover = ActionChains(driver).move_to_element(results_link)
    results_hover.perform()

    nav_header = results_item.find_element(By.CSS_SELECTOR, 'div[class="nav-header"]')
    results_anchors = nav_header.find_elements(By.TAG_NAME, 'a')
    archive_link = results_anchors[3]
    archive_hover = ActionChains(driver).move_to_element(archive_link)
    archive_hover.perform()

    archive_link.click()
    return

def get_results_archive_table_rows(driver):
    result_title = driver.find_element(By.CLASS_NAME, 'ResultsArchiveTitle').text
    print(f'\tProcessing {result_title}...')

    results_archive_table = driver.find_element(By.CSS_SELECTOR, 'table[class="resultsarchive-table"]')
    results_archive_table_body = results_archive_table.find_element(By.TAG_NAME, 'tbody')
    results_archive_table_rows = results_archive_table_body.find_elements(By.TAG_NAME, 'tr')
    return results_archive_table_rows

def process_race_results(results_archive_table_row, results_year):
    results_year_data_item = {}

    results_archive_table_cells = results_archive_table_row.find_elements(By.TAG_NAME, 'td')
    grand_prix_row = results_archive_table_cells[1].find_element(By.TAG_NAME, 'a')
    date_row = results_archive_table_cells[2]

    winner_row = results_archive_table_cells[3]
    winner_row_cells = winner_row.find_elements(By.TAG_NAME, 'span')

    car_row = results_archive_table_cells[4]
    laps_row = results_archive_table_cells[5]
    time_row = results_archive_table_cells[6]

    results_year_data_item['year'] = results_year
    results_year_data_item['grand_prix'] = grand_prix_row.text
    results_year_data_item['date'] = date_row.text
    results_year_data_item['winner'] = winner_row_cells[0].text + " " + winner_row_cells[1].text
    results_year_data_item['car'] = car_row.text
    results_year_data_item['laps'] = laps_row.text
    results_year_data_item['time'] = time_row.text
    return results_year_data_item

def process_driver_results(results_archive_table_row, results_year):
    drivers_results_years_data_item = {}
    
    results_archive_table_cells = results_archive_table_row.find_elements(By.TAG_NAME, 'td')
    driver_pos = results_archive_table_cells[1]
    driver_name = results_archive_table_cells[2]
    nationality = results_archive_table_cells[3]
    car_row = results_archive_table_cells[4]
    pts = results_archive_table_cells[5]

    drivers_results_years_data_item['year'] = results_year
    drivers_results_years_data_item['driver_pos'] = driver_pos.text
    drivers_results_years_data_item['driver_name'] = driver_name.text
    drivers_results_years_data_item['nationality'] = nationality.text
    drivers_results_years_data_item['car'] = car_row.text
    drivers_results_years_data_item['pts'] = pts.text
    return drivers_results_years_data_item

def process_team_results(results_archive_table_row, results_year):
    team_results_years_data_item = {}

    results_archive_table_cells = results_archive_table_row.find_elements(By.TAG_NAME, 'td')
    team_pos = results_archive_table_cells[1]
    team_name = results_archive_table_cells[2]
    pts = results_archive_table_cells[3]

    team_results_years_data_item['year'] = results_year
    team_results_years_data_item['team_name'] = team_name.text
    team_results_years_data_item['pts'] = pts.text
    return team_results_years_data_item

def persist_results_data(bucket_path, results_data, s3_file_name):
    print('Putting data in S3...')
    path_to_file = 'data/' + bucket_path + "/" + s3_file_name
    upload_byte_stream = bytes(json.dumps(results_data).encode('UTF-8'))
    s3.put_object(Bucket=bucket_name, Key=path_to_file, Body=upload_byte_stream)
    print('Put complete.')
    return

def init_driver():
    print("Init driver...")
    chrome_options = ChromeOptions()
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--disable-dev-tools")
    chrome_options.add_argument("--no-zygote")
    chrome_options.add_argument("--single-process")
    chrome_options.add_argument(f"--user-data-dir={mkdtemp()}")
    chrome_options.add_argument(f"--data-path={mkdtemp()}")
    chrome_options.add_argument(f"--disk-cache-dir={mkdtemp()}")
    chrome_options.add_argument("--remote-debugging-pipe")
    chrome_options.add_argument("--verbose")
    chrome_options.add_argument("--log-path=/tmp")
    chrome_options.add_argument("window-size=1920,1080")
    chrome_options.binary_location = "/opt/chrome/chrome-linux64/chrome"
    service = Service(
        executable_path="/opt/chrome-driver/chromedriver-linux64/chromedriver",
        service_log_path="/tmp/chromedriver.log"
    )
    driver = webdriver.Chrome(
        service=service,
        options=chrome_options
    )

    return driver

def lambda_handler(event, context):
    print('Start....')
    driver = init_driver()

    url = 'https://www.formula1.com/'
    driver.get(url)

    resp_data = {}

    results_categories_links = []
    results_years_links = []
    results_years_data = []
    drivers_results_years_data = []
    team_results_years_data = []

    init_page(driver)

    results_archive_filter = driver.find_element(By.CLASS_NAME, 'resultsarchive-filter-container')
    results_archive_filter_divs = results_archive_filter.find_elements(By.CSS_SELECTOR, 'div[class="resultsarchive-filter-wrap"]')

    print('Getting Result Categories links...')
    results_categories_links = get_results_categories_links(results_archive_filter_divs[1])
    
    for results_categories_link in results_categories_links:
        result_cat_title = results_categories_link['title']
        # Delte the iFrames, again, since on new page
        delete_iframes(driver)

        print(f"\nProcessing {result_cat_title} ...")
        driver.get(results_categories_link['link'])
        driver.refresh()

        results_archive_filter = driver.find_element(By.CLASS_NAME, 'resultsarchive-filter-container')
        results_archive_filter_divs = results_archive_filter.find_elements(By.CSS_SELECTOR, 'div[class="resultsarchive-filter-wrap"]')

        results_years = results_archive_filter_divs[0]
        results_year_ahchors = results_years.find_elements(By.TAG_NAME, 'a')
        results_years_links = get_archive_years(results_year_ahchors)
        
        results_years_links_cpy = results_years_links[:3] # Only process 3 records for demo

        result_cat_lower = result_cat_title.lower()

        match result_cat_title:
            case 'RACES':
                for results_years_link in results_years_links_cpy:
                    driver.get(f"https://www.formula1.com/en/results.html/{results_years_link['year']}/races.html")
                    results_archive_table_rows = get_results_archive_table_rows(driver)

                    for results_archive_table_row in results_archive_table_rows: 
                        results_years_data.append(process_race_results(results_archive_table_row, results_years_link['year']))

                # Put race_results_data.json data file in S3
                persist_results_data(result_cat_lower, results_years_data, race_results_file_name)
                resp_data['race_results'] = results_years_data

            case 'DRIVERS':
                for results_years_link in results_years_links_cpy:
                    driver.get(f"https://www.formula1.com/en/results.html/{results_years_link['year']}/drivers.html")
                    results_archive_table_rows = get_results_archive_table_rows(driver)

                    for results_archive_table_row in results_archive_table_rows: 
                        drivers_results_years_data.append(process_driver_results(results_archive_table_row, results_years_link['year']))

                # Put driver_results_data.json data file in S3
                persist_results_data(result_cat_lower, drivers_results_years_data, driver_results_file_name)
                resp_data['driver_results'] = drivers_results_years_data

            case 'TEAMS':
                for results_years_link in results_years_links_cpy:
                    if int(results_years_link['year']) >= 1958:
                        driver.get(f"https://www.formula1.com/en/results.html/{results_years_link['year']}/team.html")
                        results_archive_table_rows = get_results_archive_table_rows(driver)

                        for results_archive_table_row in results_archive_table_rows: 
                            team_results_years_data.append(process_team_results(results_archive_table_row, results_years_link['year']))

                # Put team_results_data.json data file in S3
                persist_results_data(result_cat_lower, team_results_years_data, team_results_file_name)
                resp_data['team_results'] = team_results_years_data

    body = {
        "data": resp_data
    }

    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }

    print(response)
    return response