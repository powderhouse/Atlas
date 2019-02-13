import $ from "jquery";
import mhtml2html from 'mhtml2html';

function savePage(tab) {
  chrome.pageCapture.saveAsMHTML({tabId: tab.id}, function(mhtmlBlob) {
    var fr = new FileReader();
    fr.onload = function () {
        var mhtmlData = fr.result;
        const html = mhtml2html.convert(mhtmlData);

        const formData = new FormData();
        formData.append("html", html.documentElement.outerHTML);
        formData.append("title", tab.title)
        $.ajax({
            url: 'http://localhost:1111/save',
            method: 'POST',
            type: 'POST',
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            complete: function() {
              alert("Page saved...")
            }
        });
    };
    fr.readAsBinaryString(mhtmlBlob);
  });
}

chrome.browserAction.onClicked.addListener(async function(tab) {

  // const checkCompleted = function (tabId, info) {
  //   if (tab.id == tabId && info.status === 'complete') {
  //     chrome.tabs.onUpdated.removeListener(checkCompleted);
  //
  //   }
  // }
  //
  // chrome.tabs.onUpdated.addListener(checkCompleted);

  await chrome.tabs.executeScript({
    code: "\
      const editor = document.querySelectorAll('.kix-appview-editor')[0];\
      const scrollHeight = editor.scrollHeight;\
      editor.scrollBy(0, scrollHeight);\
    "
  })

  setTimeout(function() { savePage(tab) }, 500);

});
