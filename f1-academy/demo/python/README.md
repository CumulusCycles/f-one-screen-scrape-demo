# Local Dev Machine test App
## Pre-reqs
- python and pip must be installed on your local machine

## Steps
1. Open a Terminal and execute the following
    ```
    pip install selenium webdriver-manager
    ```

2. Edit code in ```scrape.py``` to run in ```Headless mode``` or ```Launch Browser mode```

    ## Headless mode
    - uncomment lines #27 - #32
        ```python
        # Headless Browser
        options = Options()
        options.add_argument("--headless=new")
        options.add_argument('window-size=1920x1080')
        driver = webdriver.Chrome(service=ChromeService(
            ChromeDriverManager().install()), options=options)
        ```

    ## Launch Browser mode
    - uncomment lines #35 - #39
        ```python
        # Launch Browser
        options = Options()
        options.add_argument("--disable-notifications")
        driver = webdriver.Chrome(service=ChromeService(
            ChromeDriverManager().install()))
        driver.maximize_window()
        ```

3. Write data to ```team_data.json``` file (Optional)
    - uncomment ```import json``` on line #2
    - uncomment lines #167 - #169
        ```python
        f = open("team_data.json", "w")
        f.write(json.dumps(teams_data))
        f.close()
        ```

4. Write data to console (Optional)
    - uncomment line #171
        ```python
        print(json.dumps(teams_data))
        ```

5. In Terminal, execute the folllowing
    ```
    python scrape.py
    ```

####  See [data/team_data.json](/f1-academy/data/team_data.json) file for sample JSON data
