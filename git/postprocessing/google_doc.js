const puppeteer = require('puppeteer');
const fs = require('fs');

module.exports = {
  match: function (url) {
    return url.indexOf("docs.google.com/document") > -1
  },

  process: async function(url, dataDirectory) {
    const fileName = "AlecDoc"
    const data = await scrape(url)
    fs.writeFileSync(dataDirectory + "/" + fileName + ".mht", data)
  }
}

let scrape = async (url) => {
    const browser = await puppeteer.launch({headless: false});
    const page = await browser.newPage();

    await page.setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36");
    await page.setViewport({ width: 1200, height: 800 });

    const navigationPromise = page.waitForNavigation({ waitUntil: 'networkidle2' })
    await page.goto(url);
    await navigationPromise

    await page.keyboard.type("jared@puzzleschool.com")

    await page.keyboard.press("Enter")
    await page.waitFor(2000);

    await page.keyboard.type(",K$EyStsHh4kh3cU8+s9")

    const navigationPromise3 = page.waitForNavigation({ waitUntil: 'networkidle2' })
    await page.keyboard.press("Enter")
    await navigationPromise3

    page.on('console', consoleObj => console.log(consoleObj.text()));

    await autoScroll(page);

    const session = await page.target().createCDPSession();
    await session.send('Page.enable');
    const {data} = await session.send('Page.captureSnapshot');

    browser.close();
    return data;
};

async function autoScroll(page){
  await page.evaluate(async () => {
    const editor = document.querySelectorAll(".kix-appview-editor")[0];
    const scrollHeight = await editor.scrollHeight;

    await new Promise((resolve, reject) => {
        var totalHeight = 0;
        var distance = 100;
        var timer = setInterval(() => {
            editor.scrollBy(0, distance);
            totalHeight += distance;

            if(totalHeight >= scrollHeight){
                clearInterval(timer);
                resolve();
            }
        }, 100);
    });
  });
}
