const opts = require("nomnom")
   .option('url', {
      abbr: 'u',
      flag: false,
      help: 'The url for the file to be processed.'
   })
   .parse()

const googleOAuth2 = require('./google_oauth2_client')
const googleDrive = require('./google_drive')

async function main(url) {

  if (googleDrive.match(url)) {
    var oAuth2Client = await googleOAuth2.getOAuth2Client()
    googleDrive.process(url, oAuth2Client)
  }

}

main(opts.url || opts[0])
