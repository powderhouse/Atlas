// https://docs.google.com/document/d/132GhTgWTgXgJO7EzvfTEOKS3QyqdBZSfngOeaqFfIuU/edit

const {google} = require('googleapis');
const fs = require("fs");

module.exports = {

  match: function(url) {
    return url.indexOf("docs.google.com/document") > -1
  },

  process: function(docUrl, oAuth2Client) {
    const drive = google.drive({version: 'v3', auth: oAuth2Client});

    var fileId = docUrl.replace("https://docs.google.com/document/d/", "").replace("/edit", "")
    drive.files.get(
      {fileId},
      (err, res) => {
        console.log(err, res);
        var fileName = res.data.name
        const dest = fs.createWriteStream(fileName + ".docx");
        drive.files.export(
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
