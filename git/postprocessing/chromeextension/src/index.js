import $ from "jquery";
import mhtml2html from 'mhtml2html';

chrome.browserAction.onClicked.addListener(function(tab) {
  chrome.pageCapture.saveAsMHTML({tabId: tab.id}, function(mhtmlBlob) {

    var fr = new FileReader();
    fr.onload = function () {
        var mhtmlData = fr.result;
        const html = mhtml2html.convert(mhtmlData);

        const formData = new FormData();
        formData.append("html", html.documentElement.outerHTML);

        $.ajax({
            url: 'http://localhost:1111/save',
            method: 'POST',
            type: 'POST',
            data: formData,
            cache: false,
            contentType: false,
            processData: false
        });
    };
    fr.readAsBinaryString(mhtmlBlob);

  });
});
