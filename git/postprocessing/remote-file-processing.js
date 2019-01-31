const opts = require("nomnom")
   .option('url', {
      abbr: 'u',
      flag: false,
      help: 'The url for the file to be processed.'
   })
   .parse()

const googleDrive = require('./google_drive')
const youtube = require('./youtube')

const googleOAuth2 = require('./google_oauth2_client')

async function main(url) {

  if (googleDrive.match(url)) {
    var oAuth2Client = await googleOAuth2.getOAuth2Client()
    googleDrive.process(url, oAuth2Client)
  } else if (youtube.match(url)) {
    youtube.process(url)
  }

}

main(opts.url || opts[0])
