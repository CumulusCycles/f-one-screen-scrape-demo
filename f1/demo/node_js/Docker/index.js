const webdriver = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const { By, Builder } = webdriver;

const express = require('express');
const app = express();
const port = 3000;

async function deleteIframes(driver) {
    await driver.sleep(1000);
    let htmlElement = await driver.findElement(By.tagName('html'));
    await driver.executeScript("arguments[0].setAttribute('class','')", htmlElement);
    await driver.sleep(1000);
    await driver.switchTo().defaultContent();

    await driver.sleep(2000);
    let divs = await driver.findElements(By.id('sp_message_container_1149951'));
    for (let div of divs) {
        let str = 'return document.getElementById("sp_message_container_1149951").remove();';
        await driver.executeScript(str);
    }
    await driver.switchTo().parentFrame();
}

async function initDriver() {
    let chromeOptions = new chrome.Options();
    chromeOptions.addArguments('--headless', '--disable-gpu', '--no-sandbox');
    // chromeOptions.addArguments('--start-maximized', '--disable-gpu', '--no-sandbox');

    let driver = new Builder()
        .forBrowser('chrome')
        .setChromeOptions(chromeOptions)
        .build();
    return driver;
}

app.get("/", async (req, res) => {
    let resultsYearsData = [];
    let resultsYearDataItem = {};

    let driversResultsYearsData = [];
    let driversResultsYearsDataItem = {};

    let teamsResultsYearsData = [];
    let teamsResultsYearsDataItem = {};

    let driver = await initDriver();

    try {
        let url = "https://www.formula1.com/";

        let resultsCategoriesLinks = [];
        let resultsCategoriesLinkItem = {};

        await driver.get(url);

        console.log('\nOn F1 Home Page.');
        await deleteIframes(driver);

        console.log('\nGetting Primary Links...');
        let primaryLinks = await driver.findElement(By.className('primary-links'));
        let primaryLinkList = await primaryLinks.findElement(By.tagName('ul'));
        let primaryLinkItems = await primaryLinkList.findElements(By.tagName('li'));
        let resultsItem = await primaryLinkItems[4];

        console.log('\nFind Results Archive Link...');
        let navHeader = await resultsItem.findElement(By.css('div[class="nav-header"]'));
        let resultsAnchors = await navHeader.findElements(By.tagName('a'));
        let resultsAnchor = resultsAnchors[3];
        let archiveLink = resultsAnchor.getAttribute('href');

        console.log('Navigating to Results Archive page...');
        await driver.get(archiveLink);
        await driver.switchTo().defaultContent();
        await driver.sleep(1000);

        console.log('\nOn Results Archive page...');
        let resultsArchiveFilter = await driver.findElement(By.className('resultsarchive-filter-container'));
        let resultsArchiveFilterDivs = await resultsArchiveFilter.findElements(By.css('div[class="resultsarchive-filter-wrap"]'));

        console.log('Getting Result Categories links...');
        let resultsCategories = await resultsArchiveFilterDivs[1];
        let resultsCategorieItems = await resultsCategories.findElements(By.tagName('li'));

        for (let resultsCategoryItem of resultsCategorieItems) {
            let resultsCategorieItemAnchor = await resultsCategoryItem.findElement(By.tagName('a'));

            resultsCategoriesLinkItem['title'] = await resultsCategorieItemAnchor.getText();
            resultsCategoriesLinkItem['link'] = await resultsCategorieItemAnchor.getAttribute('href');
            resultsCategoriesLinks.push(resultsCategoriesLinkItem);
            resultsCategoriesLinkItem = {};
        }

        for (let resultsCategoriesLink of resultsCategoriesLinks) {
            let resultCatTitle = resultsCategoriesLink['title'];
            // Skip FASTEST LAPS Data
            if (resultCatTitle === 'FASTEST LAPS') { continue; }
            await deleteIframes(driver);

            console.log(`\nProcessing ${resultCatTitle} ...`);
            await driver.get(resultsCategoriesLink['link']);
            await driver.switchTo().defaultContent();
            await driver.sleep(1000);

            console.log('\tGetting Archive year links...');
            let resultsArchiveFilter = await driver.findElement(By.className('resultsarchive-filter-container'));
            let resultsArchiveFilterDivs = await resultsArchiveFilter.findElements(By.css('div[class="resultsarchive-filter-wrap"]'));

            let resultsYears = resultsArchiveFilterDivs[0];
            let resultsYearAnchors = await resultsYears.findElements(By.tagName('a'));

            let resultsYearsLinks = [];
            let resultsYearsLinkItem = {};
            for (let resultsYearAnchor of resultsYearAnchors) {
                let resultsYearAnchorSpan = await resultsYearAnchor.findElement(By.tagName('span'));
                resultsYearsLinkItem['year'] = await resultsYearAnchorSpan.getAttribute('innerHTML');
                resultsYearsLinkItem['link'] = await resultsYearAnchor.getAttribute('href');
                resultsYearsLinks.push(resultsYearsLinkItem);
                resultsYearsLinkItem = {};
            }
            let resultsYearsLinksCpy = resultsYearsLinks.splice(0, 3); // Only process 3 records for demo

            switch (resultCatTitle) {
                case 'RACES':
                    for (let resultsYearsLink of resultsYearsLinksCpy) {
                        await driver.get(`https://www.formula1.com/en/results.html/${resultsYearsLink['year']}/races.html`);

                        let resultTitle = await driver.findElement(By.className('ResultsArchiveTitle')).getText();
                        console.log(`\tProcessing ${resultTitle}...`);

                        let resultsarchiveTable = await driver.findElement(By.css('table[class="resultsarchive-table"]'));
                        let resultsarchiveTableBody = await resultsarchiveTable.findElement(By.tagName('tbody'));
                        let resultsarchiveTableRows = await resultsarchiveTableBody.findElements(By.tagName('tr'));

                        for (let resultsarchiveTableRow of resultsarchiveTableRows) {
                            let resultsArchiveTableCells = await resultsarchiveTableRow.findElements(By.tagName('td'));
                            let grandPrixRow = await resultsArchiveTableCells[1].findElement(By.tagName('a'));
                            let dateRow = resultsArchiveTableCells[2];

                            let winnerRow = resultsArchiveTableCells[3];
                            let winnerRowCells = await winnerRow.findElements(By.tagName('span'));

                            let carRow = resultsArchiveTableCells[4];
                            let lapsRow = resultsArchiveTableCells[5];
                            let timeRow = resultsArchiveTableCells[6];

                            resultsYearDataItem['year'] = resultsYearsLink['year'];
                            resultsYearDataItem['grand_prix'] = await grandPrixRow.getText();
                            resultsYearDataItem['date'] = await dateRow.getText();
                            resultsYearDataItem['winner'] = await winnerRowCells[0].getText() + " " + await winnerRowCells[1].getText();
                            resultsYearDataItem['car'] = await carRow.getText();
                            resultsYearDataItem['laps'] = await lapsRow.getText();
                            resultsYearDataItem['time'] = await timeRow.getText();
                            resultsYearsData.push(resultsYearDataItem);
                            resultsYearDataItem = {};
                        }
                    }
                    // console.log(resultsYearsData);
                    break;

                case 'DRIVERS':
                    for (let resultsYearsLink of resultsYearsLinksCpy) {
                        await driver.get(`https://www.formula1.com/en/results.html/${resultsYearsLink['year']}/drivers.html`);
                        let resultTitle = await driver.findElement(By.className('ResultsArchiveTitle')).getText();
                        console.log(`\tProcessing ${resultTitle}...`);

                        let resultsarchiveTable = await driver.findElement(By.css('table[class="resultsarchive-table"]'));
                        let resultsarchiveTableBody = await resultsarchiveTable.findElement(By.tagName('tbody'));
                        let resultsarchiveTableRows = await resultsarchiveTableBody.findElements(By.tagName('tr'));

                        for (let resultsarchiveTableRow of resultsarchiveTableRows) {
                            let resultsArchiveTableCells = await resultsarchiveTableRow.findElements(By.tagName('td'));
                            let driverPos = resultsArchiveTableCells[1];
                            let driverName = resultsArchiveTableCells[2];
                            let nationality = resultsArchiveTableCells[3];
                            let carRow = resultsArchiveTableCells[4];
                            let pts = resultsArchiveTableCells[5];

                            driversResultsYearsDataItem['year'] = resultsYearsLink['year'];
                            driversResultsYearsDataItem['driverPos'] = await driverPos.getText();
                            driversResultsYearsDataItem['driverName'] = await driverName.getText();
                            driversResultsYearsDataItem['nationality'] = await nationality.getText();
                            driversResultsYearsDataItem['car'] = await carRow.getText();
                            driversResultsYearsDataItem['pts'] = await pts.getText();
                            driversResultsYearsData.push(driversResultsYearsDataItem);
                            driversResultsYearsDataItem = {};
                        }
                    }
                    // console.log(driversResultsYearsData);
                    break;

                case 'TEAMS':
                    for (let resultsYearsLink of resultsYearsLinksCpy) {
                        if (parseInt(resultsYearsLink['year']) >= 1958) {
                            await driver.get(`https://www.formula1.com/en/results.html/${resultsYearsLink['year']}/team.html`);
                            let resultTitle = await driver.findElement(By.className('ResultsArchiveTitle')).getText();
                            console.log(`\tProcessing ${resultTitle}...`);

                            let resultsarchiveTable = await driver.findElement(By.css('table[class="resultsarchive-table"]'));
                            let resultsarchiveTableBody = await resultsarchiveTable.findElement(By.tagName('tbody'));
                            let resultsarchiveTableRows = await resultsarchiveTableBody.findElements(By.tagName('tr'));

                            for (let resultsarchiveTableRow of resultsarchiveTableRows) {
                                let resultsArchiveTableCells = await resultsarchiveTableRow.findElements(By.tagName('td'));
                                let teamPos = resultsArchiveTableCells[1];
                                let teamName = resultsArchiveTableCells[2];
                                let pts = resultsArchiveTableCells[3];

                                teamsResultsYearsDataItem['year'] = resultsYearsLink['year'];
                                teamsResultsYearsDataItem['teamName'] = await teamName.getText();
                                teamsResultsYearsDataItem['pts'] = await pts.getText();
                                teamsResultsYearsData.push(teamsResultsYearsDataItem);
                                teamsResultsYearsDataItem = {};
                            }
                        }
                    }
                    // console.log(teamsResultsYearsData);
                    break;
            }
        }
    } catch (e) {
        console.log('An Exception was thrown:');
        console.log(e);
    } finally {
        console.log('End.');
        await driver.quit();
        res.json([
            { "resultsYearsData": resultsYearsData },
            { "driversResultsYearsData": driversResultsYearsData },
            { "teamsResultsYearsData": teamsResultsYearsData }
        ]);
    }
});

app.listen(port, () => {
    console.log(`Scrape App listening on port ${port}.`);
});