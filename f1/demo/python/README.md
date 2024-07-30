# Local Dev Machine execution
## Pre-reqs
- python and pip must be installed on your local machine

## Steps
1. Open a Terminal and execute the following
    ```
    pip install selenium webdriver-manager
    ```

2. Edit code ```scrape.py``` to run in ```Headless mode``` or ```Launch Browser mode```

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

3. Write data to ```json``` file (Optional)
    - uncomment ```import json``` on line #2
    - uncomment lines to write to file
    - ex
        ```python
        f = open("race_results.json", "w")
        f.write(json.dumps(results_years_data))
        f.close()
        ```

4. Write data to console (Optional)
    - uncomment line to print to console
    - ex
        ```python
        print(json.dumps(results_years_data))
        ```

5. In Terminal, execute the folllowing
    ```
    python FILE_NAME.py
    ```

#### See [data/*.json](/f1/data/) files for sample JSON data
