require('dotenv').config();

const webdriver = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const { By, Builder } = webdriver;

const express = require('express');
const app = express();
const port = 3000;

// AWS Config
const AWS = require('aws-sdk');
const s3Config = {
    apiVersion: '2012-10-17',
    region: process.env.AWS_REGION,
    accessKeyId: process.env.AWS_ACCESS_KEY,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
};
AWS.config.update(s3Config);

// S3
const s3 = new AWS.S3(
    {
        region: process.env.AWS_REGION,
        accessKey: process.env.AWS_ACCESS_KEY,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    }
);

const bucketName = process.env.BUCKET_NAME;
const raceResultsFileName = 'race_results_data.json';
const driverResultsFileName = 'driver_results_data.json';
const teamResultsFileName = 'team_results_data.json';

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

    let driver = new Builder()
        .forBrowser('chrome')
        .setChromeOptions(chromeOptions)
        .build();
    return driver;
}

async function persistResultsData(bucketPath, resultsData, s3FileName) {
    console.log('Putting data in S3...');

    const resultsDataString = JSON.stringify(resultsData);
    const pathToFile = `data/${bucketPath}/${s3FileName}`;
    
    console.log(`Key: ${pathToFile}`);
    console.log(resultsDataString);

    const params = {
        Bucket: bucketName,
        Key: pathToFile,
        Body: resultsDataString
    };
    await s3.upload(params, (err, data) => {
        if (err) {
            // console.log('Error uploading file:', err);
        }
    }).promise();

    console.log('Put complete.');
}

app.get("/", async (req, res) => {
    console.log('Starting...');

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
        let resultsArchiveFilter = await driver.findElement(By.css('div[class="f1-container container"]'));
        let resultsArchiveFilterDivsContainer = await resultsArchiveFilter.findElement(By.css('div[class="grid max-laptop:gap-xs laptop:grid-cols-3 laptop:divide-x"]'));
        let resultsArchiveFilterDivs = await resultsArchiveFilterDivsContainer.findElements(By.tagName('details'));

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
            let resultsArchiveFilter = await driver.findElement(By.css('div[class="f1-container container"]'));
            let resultsArchiveFilterDivsContainer = await resultsArchiveFilter.findElement(By.css('div[class="grid max-laptop:gap-xs laptop:grid-cols-3 laptop:divide-x"]'));
            let resultsArchiveFilterDivs = await resultsArchiveFilterDivsContainer.findElements(By.tagName('details'));

            let resultsYears = resultsArchiveFilterDivs[0];
            let resultsYearAnchors = await resultsYears.findElements(By.tagName('a'));

            let resultsYearsLinks = [];
            let resultsYearsLinkItem = {};
            for (let resultsYearAnchor of resultsYearAnchors) {
                resultsYearsLinkItem['year'] = await resultsYearAnchor.getAttribute('innerHTML');
                resultsYearsLinkItem['link'] = await resultsYearAnchor.getAttribute('href');
                resultsYearsLinks.push(resultsYearsLinkItem);
                resultsYearsLinkItem = {};
            }
            let resultsYearsLinksCpy = resultsYearsLinks.splice(0, 3); // Only process 3 records for demo
            let resultCatLower = resultCatTitle.toLowerCase();

            switch (resultCatTitle) {
                case 'RACES':
                    for (let resultsYearsLink of resultsYearsLinksCpy) {
                        await driver.get(`https://www.formula1.com/en/results.html/${resultsYearsLink['year']}/races.html`);

                        let resultTitle = await driver.findElement(By.tagName('h1')).getText();
                        console.log(`\tProcessing ${resultTitle}...`);

                        let resultsArchiveTable = await driver.findElement(By.css('table[class="f1-table f1-table-with-data w-full"]'));
                        let resultsArchiveTableBody = await resultsArchiveTable.findElement(By.tagName('tbody'));
                        let resultsArchiveTableRows = await resultsArchiveTableBody.findElements(By.tagName('tr'));

                        for (let resultsArchiveTableRow of resultsArchiveTableRows) {
                            let resultsArchiveTableCells = await resultsArchiveTableRow.findElements(By.tagName('td'));

                            let grandPrixRow = resultsArchiveTableCells[0];
                            let dateRow = resultsArchiveTableCells[1];
                            
                            let winnerRowCell = resultsArchiveTableCells[2];
                            let winnerNameContent = await winnerRowCell.findElements(By.tagName('span'));
                            let winnerFName = await winnerNameContent[0].getAttribute('innerHTML');
                            let winnerLName = await winnerNameContent[1].getText();

                            let carRow = resultsArchiveTableCells[3];
                            let lapsRow =  resultsArchiveTableCells[4];
                            
                            let timeRow = resultsArchiveTableCells[5];
                            let timeRowPara = await timeRow.findElement(By.tagName('p'));

                            resultsYearDataItem['year'] = resultsYearsLink['year'];
                            resultsYearDataItem['grand_prix'] = await grandPrixRow.getText();
                            resultsYearDataItem['date'] = await dateRow.getText();
                            resultsYearDataItem['winner'] = `${winnerFName} ${winnerLName}`;
                            resultsYearDataItem['car'] = await carRow.getText();
                            resultsYearDataItem['laps'] = await lapsRow.getText();
                            resultsYearDataItem['time'] = await timeRowPara.getAttribute('innerHTML');
                            resultsYearsData.push(resultsYearDataItem);
                            resultsYearDataItem = {};
                        }
                    }
                    // console.log(resultsYearsData);
                    // Put race_results_data.json data file in S3
                    await persistResultsData(resultCatLower, resultsYearsData, raceResultsFileName);
                    break;

                case 'DRIVERS':
                    for (let resultsYearsLink of resultsYearsLinksCpy) {
                        await driver.get(`https://www.formula1.com/en/results.html/${resultsYearsLink['year']}/drivers.html`);

                        let resultTitle = await driver.findElement(By.tagName('h1')).getText();
                        console.log(`\tProcessing ${resultTitle}...`);

                        let resultsArchiveTable = await driver.findElement(By.css('table[class="f1-table f1-table-with-data w-full"]'));
                        let resultsArchiveTableBody = await resultsArchiveTable.findElement(By.tagName('tbody'));
                        let resultsArchiveTableRows = await resultsArchiveTableBody.findElements(By.tagName('tr'));

                        for (let resultsArchiveTableRow of resultsArchiveTableRows) {
                            let resultsArchiveTableCells = await resultsArchiveTableRow.findElements(By.tagName('td'));

                            let driverPos = resultsArchiveTableCells[0];

                            let driverNameCell = resultsArchiveTableCells[1];
                            let driverNameContent = await driverNameCell.findElements(By.tagName('span'));
                            let driverFName = await driverNameContent[0].getAttribute('innerHTML');
                            let driverLName = await driverNameContent[1].getText();

                            let nationality = resultsArchiveTableCells[2];
                            let carRow = resultsArchiveTableCells[3];
                            let pts = resultsArchiveTableCells[4];

                            driversResultsYearsDataItem['year'] = resultsYearsLink['year'];
                            driversResultsYearsDataItem['driver_pos'] = await driverPos.getText();
                            driversResultsYearsDataItem['driver_name'] =  `${driverFName} ${driverLName}`;
                            driversResultsYearsDataItem['nationality'] = await nationality.getText();
                            driversResultsYearsDataItem['car'] = await carRow.getText();
                            driversResultsYearsDataItem['pts'] = await pts.getText();
                            driversResultsYearsData.push(driversResultsYearsDataItem);
                            driversResultsYearsDataItem = {};
                        }
                    }
                    // console.log(driversResultsYearsData);
                    // Put driver_results_data.json data file in S3
                    await persistResultsData(resultCatLower, driversResultsYearsData, driverResultsFileName);
                    break;

                case 'TEAMS':
                    for (let resultsYearsLink of resultsYearsLinksCpy) {
                        if (parseInt(resultsYearsLink['year']) >= 1958) {
                            await driver.get(`https://www.formula1.com/en/results.html/${resultsYearsLink['year']}/team.html`);

                            let resultTitle = await driver.findElement(By.tagName('h1')).getText();
                            console.log(`\tProcessing ${resultTitle}...`);

                            let resultsArchiveTable = await driver.findElement(By.css('table[class="f1-table f1-table-with-data w-full"]'));
                            let resultsArchiveTableBody = await resultsArchiveTable.findElement(By.tagName('tbody'));
                            let resultsArchiveTableRows = await resultsArchiveTableBody.findElements(By.tagName('tr'));

                            for (let resultsArchiveTableRow of resultsArchiveTableRows) {
                                let resultsArchiveTableCells = await resultsArchiveTableRow.findElements(By.tagName('td'));

                                let teamPos = resultsArchiveTableCells[0];
                                let teamName = resultsArchiveTableCells[1];
                                let pts = resultsArchiveTableCells[2];

                                teamsResultsYearsDataItem['year'] = resultsYearsLink['year'];
                                teamsResultsYearsDataItem['team_name'] = await teamName.getText();
                                teamsResultsYearsDataItem['pts'] = await pts.getText();
                                teamsResultsYearsData.push(teamsResultsYearsDataItem);
                                teamsResultsYearsDataItem = {};
                            }
                        }
                    }
                    // console.log(teamsResultsYearsData);
                    // Put team_results_data.json data file in S3
                    await persistResultsData(resultCatLower, teamsResultsYearsData, teamResultsFileName);
                    break;
            }
        }
    } catch (e) {
        console.log('An Exception was thrown:');
        console.log(e);
    } finally {
        await driver.quit();
        res.json([
            { "resultsYearsData": resultsYearsData },
            { "driversResultsYearsData": driversResultsYearsData },
            { "teamsResultsYearsData": teamsResultsYearsData }
        ]);
        console.log('End.');
    }
});

app.listen(port, () => {
    console.log(`Scrape App listening on port ${port}.`);
});