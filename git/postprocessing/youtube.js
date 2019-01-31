// https://www.youtube.com/watch?v=KKvxvYnYck8&t=3s
// https://studio.youtube.com/video/KKvxvYnYck8/edit

const fs = require("fs");
const ytdl = require('ytdl-core');

module.exports = {
  match: function(url) {
    if (url.indexOf("youtube.com")) {
      return (url.indexOf("/watch") > -1 || url.indexOf("/video") > -1)
    }
    return false
  },

  process: function(url) {
    ytdl.getInfo(url, (err, info) => {
      if (err) throw err;
      ytdl.downloadFromInfo(info, { filter: (format) => format.container === 'mp4' })
        .pipe(fs.createWriteStream(info.title + ".mp4"));
    });


  }
}
