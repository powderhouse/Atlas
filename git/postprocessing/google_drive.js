// https://docs.google.com/document/d/132GhTgWTgXgJO7EzvfTEOKS3QyqdBZSfngOeaqFfIuU/edit

const googleOAuth2 = require('./google_oauth2_client')
const {google} = require('googleapis');
const fs = require("fs");

module.exports = {

  match: function(url) {
    return false
    return url.indexOf("docs.google.com/document") > -1
  },

  process: async function(docUrl, dataDirectory) {
    const oAuth2Client = await googleOAuth2.getOAuth2Client(dataDirectory)
    const drive = google.drive({version: 'v3', auth: oAuth2Client});

    var fileId = docUrl.replace("https://docs.google.com/document/d/", "").replace("/edit", "")
    drive.files.get(
      {fileId},
      async (err, res) => {
        if (err) {
          console.log("Error with: ", oAuth2Client)
          console.error(err);
          throw err;
        };

        var fileName = res.data.name
        const dest = fs.createWriteStream(dataDirectory + "/" + fileName + ".docx");
        await drive.files.export(
          { fileId, mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' },
          { responseType: 'stream' },
          (err, res) => {
            if (err) {
              console.error(err);
              throw err;
            }
            res.data.on('end', () => {
              console.log('Done downloading document.');
              // callback();
            })
              .on('error', err => {
                console.error('Error downloading document.');
                throw err;
              })
              .pipe(dest);
          });
      }
    )
  }
}
