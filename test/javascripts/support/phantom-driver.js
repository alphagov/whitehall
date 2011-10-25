if (phantom.state.length === 0) {
    if (phantom.args.length === 0 || phantom.args.length > 2) {
        console.log('Usage: run-qunit.js URL');
        phantom.exit();
    } else {
        phantom.state = 'run-qunit';
        phantom.open(phantom.args[0]);
    }
} else {
    setInterval(function() {
        var el = document.getElementById('qunit-testresult');
        if (phantom.state !== 'finish') {
            if (el && el.innerText.match('completed')) {
                phantom.state = 'finish';
                console.log(el.innerText);
                failedCount = null;
                try {
                    var listOfTests = document.getElementById("qunit-tests");
                    for(var i = 0; i < listOfTests.childNodes.length; i++) {
                        var testItem = listOfTests.childNodes[i];
                        if (testItem.className == "fail") {
                          var moduleName = testItem.getElementsByClassName("module-name")[0].innerText;
                          var testName = testItem.getElementsByClassName("test-name")[0].innerText;
                          var counts = testItem.getElementsByClassName("counts")[0].innerText;
                          var failures = testItem.getElementsByClassName("fail")
                          for(var j = 0; j < failures.length; j++) {
                            console.log("Test failure - " + moduleName + ": " + testName + " " + counts + " " + failures[j].innerText);
                          }
                        }
                    }
                    failedElements = el.getElementsByClassName('failed');
                    failedCount = failedElements[0].innerHTML;
                } catch (e) {
                  console.log("Exception parsing test results: " + e);
                }
                phantom.exit((parseInt(failedCount, 10) > 0) ? 1 : 0);
            }
        }
    }, 100);
}