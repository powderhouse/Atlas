const opts = require("nomnom")
   .option('url', {
      abbr: 'u',
      flag: false,
      help: 'The url for the file to be processed.'
   })
   .option('dir', {
     abbr: 'd',
     flag: false,
     help: 'The directory where processed files and user authentication information is stored.'
   })
   .parse()

const services = [
  'google_drive',
  'youtube'
]

async function main(url, dataDirectory) {

  for (var i=0; i<services.length; ++i) {
    const service = require('./' + services[i])
    if (service.match(url)) {
      service.process(url, dataDirectory)
    }
  }

}

main(opts.url || opts[0], opts.dir || opts[1] || ".")
