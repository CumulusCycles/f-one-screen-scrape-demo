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
    let divs = await driver.findElements(By.id('sp_message_container_1033520'));
    for (let div of divs) {
        let str = 'return document.getElementById("sp_message_container_1033520").remove();';
        await driver.executeScript(str);
    }
    await driver.switchTo().parentFrame();
}

async function doHover(driver, ele) {
    try {
        const actions = await driver.actions({ async: true });
        await actions.move({ origin: ele }).perform();
    } catch (e) {
        await driver.executeScript("window.scrollTo(0, document.body.scrollHeight)");
    }
    await driver.sleep(1000);
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
    let teamsData = [];
    let driver = await initDriver();

    try {
        let url = 'https://www.f1academy.com/';

        let teamsDataItem = {};
        let driversData = [];
        let driversDataItem = {};

        console.log(`\nLoad: ${url}`);
        await driver.get(url);

        console.log('\nOn F1 Academy Home Page.');
        await deleteIframes(driver);

        console.log('\nGetting Primary Links...');
        let primaryLinks = await driver.findElement(By.className('primary-links'));
        let racingSeries = await driver.findElement(By.id('Racing-Series'));
        await doHover(driver, racingSeries);

        let subNav = await primaryLinks.findElement(By.className('nav-width'));
        let items = await subNav.findElements(By.tagName('li'));

        console.log('Looking for Teams link...');
        for (let item of items) {
            let itemLink = await item.getAttribute('innerHTML');
            if (itemLink.includes('Teams')) {
                console.log('Navigating to Teams page...');
                let teamLinkAnchor = await item.findElement(By.tagName('a'));
                let teamLinkHref = await teamLinkAnchor.getAttribute('href');
                await driver.get(teamLinkHref);
                break;
            }
        }

        await deleteIframes(driver);
        await driver.sleep(1000);

        console.log('\nOn Teams page.');
        console.log('Getting Teams...');
        let teams = await driver.findElements(By.xpath('//div[@class="teams-driver-item col-12 col-md-6 col-lg-4 col-xl-4"]'));

        console.log('\nProcessing Teams...');
        for (let team of teams) {
            await doHover(driver, team);

            let teamName = await team.findElement(By.className('brand-link')).getText();
            let teamWrapper = await team.findElement(By.className('wrapper'));
            let teamLink = await teamWrapper.findElement(By.tagName('a'));
            let teamLogo = await teamLink.findElement(By.className('brand')).findElement(By.tagName('img'));

            console.log(`\tProcessing: ${teamName}`);
            teamsDataItem['team_name'] = teamName;
            teamsDataItem['team_link'] = teamLink.getAttribute('href');
            teamsDataItem['team_logo'] = teamLogo.getAttribute('src');
            teamsData.push(teamsDataItem);

            console.log('\t\tGetting Drivers...');
            let driversClass = await team.findElement(By.className('drivers'));
            let drivers = await driversClass.findElements(By.css('div[class="driver"]'));

            console.log('\t\tProcessing Drivers...');
            for (let teamDriver of drivers) {
                let driverNameEle = await teamDriver.findElement(By.className('name'));
                let driverLink = await teamDriver.findElement(By.tagName('a'));
                let driverImg = await teamDriver.findElement(By.tagName('img'));
                await doHover(driver, driverImg);

                let driverName = await driverNameEle.getText();
                console.log(`\t\t\tProcessing: ${driverName}`);
                driversDataItem['driver_name'] = driverName.trim();
                driversDataItem['driver_link'] = await driverLink.getAttribute('href');
                driversDataItem['driver_img'] = await driverImg.getAttribute('src');
                driversData.push(driversDataItem);

                driversDataItem = {};
            }

            console.log('');
            teamsDataItem['drivers_data'] = driversData;
            driversData = [];
            teamsDataItem = {};
        }

        // Get additional Team data
        for (let team of teamsData) {
            let teamLink = team['team_link'];
            await driver.get(teamLink);
            await deleteIframes(driver);

            console.log(`Processing ${team['team_name']} details...`);
            let teamDetailDiv = await driver.findElement(By.className('teamdetail'));
            let teamImageDiv = await teamDetailDiv.findElement(By.css('div[class="row teamdetail-car-image-wrapper"]'));
            let teamImage = await teamImageDiv.findElement(By.tagName('img'));

            let teamDetail = await driver.findElement(By.css('ul[class="row teamdetail-profile--info"]'));
            let teamListItems = await teamDetail.findElements(By.tagName('li'));

            let teamCountyInfo = await teamListItems[0].findElement(By.tagName('img'));
            let teamBaseInfo = await teamListItems[1].findElement(By.css('div[class="bold-font"]'));

            team['team_image'] = await teamImage.getAttribute('src');
            team['team_county_flag'] = await teamCountyInfo.getAttribute('src');
            team['team_county_name'] = await teamCountyInfo.getAttribute('alt');
            team['team_base_info'] = await teamBaseInfo.getText();

            // Get additional Driver data
            console.log('\tProcessing drivers...');
            for (let driverData of team['drivers_data']) {
                console.log(`\t\tProcessing: ${driverData['driver_name']}`);
                let driverLink = driverData['driver_link'];
                await driver.get(driverLink);
                await deleteIframes(driver);

                let driverDetailDiv = await driver.findElement(By.css('div[class="common-driver-info driveretail-drivers--info"]'));
                let driverListItems = await driverDetailDiv.findElements(By.tagName('li'));

                let driverDob = await driverListItems[0].findElement(By.tagName('h4')).getText();
                let driverNationality = await driverListItems[1].findElement(By.tagName('h4')).getText();
                let driverSupporter = await driverListItems[2].findElement(By.tagName('h4')).getText();

                let commonDriverInfoPropsDiv = await driver.findElement(By.css('div[class="common-driver-info--props"]'));
                await driver.executeScript('arguments[0].scrollIntoView();', commonDriverInfoPropsDiv);

                let driverFlagSpan = await driver.findElement(By.css('span[class="common-driver-info--flag"]'));
                let driverFlag = await driverFlagSpan.findElement(By.tagName('img')).getAttribute('src');

                driverData['driver_dob'] = driverDob;
                driverData['driver_nationality'] = driverNationality;
                driverData['driver_flag'] = driverFlag;
                driverData['driver_supporter'] = driverSupporter;
            }
        }
    } catch (e) {
        console.log('An Exception was thrown:');
        console.log(e);
    } finally {
        console.log('End.');
        await driver.quit();
        res.json({ data: teamsData });
    }
});

app.listen(port, () => {
    console.log(`Scrape App listening on port ${port}.`)
});