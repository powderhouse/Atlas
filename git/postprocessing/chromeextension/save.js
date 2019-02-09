chrome.browserAction.onClicked.addListener(function(tab) {
  alert(tab.url);

  // $.get("http://localhost:1111", function() { alert("HI") })

  chrome.pageCapture.saveAsMHTML({tabId: tab.id}, function(mhtmlData) {

    var data = new FormData();
    data.append("mhtml", mhtmlData)
    $.ajax({
        url: 'http://localhost:1111/save',
        method: 'POST',
        type: 'POST',
        data: data,
        cache: false,
        contentType: false,
        processData: false
    });

  });
});
