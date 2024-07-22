# Local Dev Machine execution
## Pre-reqs
- python and pip must be installed on your local machine

## Apps
- ```scrape_race_results.py```: Scrape only Race Results from 1950 - current
- ```scrape_driver_standings.py```: Scrape only Driver Standings from 1950 - current
- ```scrape_race_standings.py```: Scrape only Team Standings from 1958 - current
- ```scrape.py```: Scrape all Race, Driver and Team results

## Steps
1. Open a Terminal and execute the following
    ```
    pip install selenium webdriver-manager
    ```

2. Open appropriate python file you wish to execute

3. Edit code to run in ```Headless mode``` or ```Launch Browser mode```

    ## Headless mode
    - uncomment lines
        ```python
        # Headless Browser
        options = Options()
        options.add_argument("--headless=new")
        options.add_argument('window-size=1920x1080')
        driver = webdriver.Chrome(service=ChromeService(
            ChromeDriverManager().install()), options=options)
        ```

    ## Launch Browser mode
    - uncomment lines
        ```python
        # Launch Browser
        options = Options()
        options.add_argument("--disable-notifications")
        driver = webdriver.Chrome(service=ChromeService(
            ChromeDriverManager().install()))
        driver.maximize_window()
        ```

4. Write data to ```json``` file (Optional)
    - uncomment ```import json``` on line #2
    - uncomment lines to write to file
    - ex
        ```python
        f = open("race_results.json", "w")
        f.write(json.dumps(results_years_data))
        f.close()
        ```

5. Write data to console (Optional)
    - uncomment line to print to console
    - ex
        ```python
        print(json.dumps(results_years_data))
        ```

6. In Terminal, execute the folllowing
    ```
    python FILE_NAME.py
    ```

#### See [data/*.json](/f1/data/) files for sample JSON data
