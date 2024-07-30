import time
# import json

from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager

def delete_iframes(driver):
    time.sleep(2)
    divs = driver.find_elements(By.ID, 'sp_message_container_1033520')
    for indx, div in enumerate(divs):
        str = 'return document.getElementById("sp_message_container_1033520").remove();'
        driver.execute_script(str)
    html_element = driver.find_element(By.TAG_NAME, 'html')
    driver.execute_script("arguments[0].setAttribute('class','')", html_element)
    driver.switch_to.default_content()

def do_hover(ele):
    hover = ActionChains(driver).move_to_element(ele)
    hover.perform()
    time.sleep(1)

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

url = 'https://www.f1academy.com/'

teams_data = []
teams_data_item = {}
drivers_data = []
drivers_data_item = {}

try:    
    print(f'\nLoad: {url}')
    driver.get(url)

    print('On F1 Academy Home Page.')
    delete_iframes(driver)

    print('\nGetting Primary Links...')
    primary_links = driver.find_element(By.CLASS_NAME, 'primary-links')
    racing_series = driver.find_element(By.ID, 'Racing-Series')
    do_hover(racing_series)

    sub_nav = primary_links.find_element(By.CLASS_NAME, 'nav-width')
    items = sub_nav.find_elements(By.TAG_NAME, 'li')
    
    print('Looking for Teams link...')
    for item in items:
        if 'Teams' in item.get_attribute('innerHTML'):
            print('Navigating to Teams page...')
            team_link = item.find_element(By.TAG_NAME, 'a').click()

    time.sleep(1)
    # f = open("teams.html", "w")
    # f.write(driver.page_source)
    # f.close()

    print('\nOn Teams page.')
    print('Getting Teams...')
    teams = driver.find_elements(By.XPATH, '//div[@class="teams-driver-item col-12 col-md-6 col-lg-4 col-xl-4"]')
    
    print('\nProcessing Teams...')
    for team in teams:
        do_hover(team)

        team_name = team.find_element(By.CLASS_NAME, 'brand-link').text
        team_wrapper = team.find_element(By.CLASS_NAME, 'wrapper')
        team_link = team_wrapper.find_element(By.TAG_NAME, 'a')
        team_logo = team_link.find_element(By.CLASS_NAME, 'brand').find_element(By.TAG_NAME, 'img')
        
        print(f'\tProcessing: {team_name}')
        teams_data_item['team_name'] = team_name
        teams_data_item['team_link'] = team_link.get_attribute('href')
        teams_data_item['team_logo'] = team_logo.get_attribute('src')
        teams_data.append(teams_data_item)

        print('\t\tGetting Drivers...')
        drivers_class = team.find_element(By.CLASS_NAME, 'drivers')
        drivers = drivers_class.find_elements(By.CSS_SELECTOR, 'div[class="driver"]')
        
        print('\t\tProcessing Drivers...')
        for team_driver in drivers:
            driver_name = team_driver.find_element(By.CLASS_NAME, 'name')
            driver_link = team_driver.find_element(By.TAG_NAME, 'a')
            driver_img = team_driver.find_element(By.TAG_NAME, 'img')            
            do_hover(driver_img)

            print(f'\t\t\tProcessing: {driver_name.text}')
            drivers_data_item['driver_name'] = driver_name.text.strip()
            drivers_data_item['driver_link'] = driver_link.get_attribute('href')
            drivers_data_item['driver_img'] = driver_img.get_attribute('src')
            drivers_data.append(drivers_data_item)

            drivers_data_item = {}
        
        print('')
        teams_data_item['drivers_data'] = drivers_data
        drivers_data = []
        teams_data_item = {}

    # Get additional Team data
    for team in teams_data:
        team_link = team['team_link']
        driver.get(team_link)
        delete_iframes(driver)

        print(f'Processing {team['team_name']} details...')
        team_detail_div = driver.find_element(By.CLASS_NAME, 'teamdetail') 
        team_image_div = team_detail_div.find_element(By.CSS_SELECTOR, 'div[class="row teamdetail-car-image-wrapper"]')
        team_image = team_image_div.find_element(By.TAG_NAME, 'img')
        
        team_detail = driver.find_element(By.CSS_SELECTOR, 'ul[class="row teamdetail-profile--info"]')
        team_list_items = team_detail.find_elements(By.TAG_NAME, 'li')

        team_county_info = team_list_items[0].find_element(By.TAG_NAME, 'img')
        team_base_info = team_list_items[1].find_element(By.CSS_SELECTOR, 'div[class="bold-font"]')

        team['team_image'] = team_image.get_attribute('src')
        team['team_county_flag'] = team_county_info.get_attribute('src')
        team['team_county_name'] = team_county_info.get_attribute('alt')
        team['team_base_info'] = team_base_info.text.title()

        # Get additional Driver data
        print(f'\tProcessing driver details...')
        for driver_data in team['drivers_data']:
            print(f'\t\tProcessing: {driver_data['driver_name']}')
            driver_link = driver_data['driver_link']
            driver.get(driver_link)
            delete_iframes(driver)

            driver_detail_div = driver.find_element(By.CSS_SELECTOR, 'div[class="common-driver-info driveretail-drivers--info"]')
            driver_list_items = driver_detail_div.find_elements(By.TAG_NAME, 'li')

            driver_dob = driver_list_items[0].find_element(By.TAG_NAME, 'h4').text
            driver_nationality = driver_list_items[1].find_element(By.TAG_NAME, 'h4').text
            driver_supporter = driver_list_items[2].find_element(By.TAG_NAME, 'h4').text

            time.sleep(1)
            common_driver_info_props_div = driver.find_element(By.CSS_SELECTOR, 'div[class="common-driver-info--props"]')
            driver.execute_script('arguments[0].scrollIntoView();', common_driver_info_props_div)

            driver_flag_span = driver.find_element(By.CSS_SELECTOR, 'span[class="common-driver-info--flag"]')
            driver_flag = driver_flag_span.find_element(By.TAG_NAME, 'img').get_attribute('src')
            
            driver_data['driver_dob'] = driver_dob
            driver_data['driver_nationality'] = driver_nationality
            driver_data['driver_flag'] = driver_flag
            driver_data['driver_supporter'] = driver_supporter
        print('')

    # f = open("team_data.json", "w")
    # f.write(json.dumps(teams_data))
    # f.close()

    # print(json.dumps(teams_data))
except Exception as e:
    print('Error:')
    print(e)

print('\nComplete.')
time.sleep(3)
driver.close()
driver.quit()
