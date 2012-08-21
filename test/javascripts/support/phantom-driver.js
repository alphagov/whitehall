/*
 * Qt+WebKit powered (mostly) headless test runner using Phantomjs
 *
 * Phantomjs installation: http://code.google.com/p/phantomjs/wiki/BuildInstructions
 *
 * Run with:
 *  phantomjs test.js [url-of-your-qunit-testsuite]
 *
 * E.g.
 *      phantomjs test.js http://localhost/qunit/test
 */

var url = phantom.args[0],
    page = require('webpage').create(),
    fs = require("fs"),
    lastTestCount, lastTestCountChange = +new Date(),
    timeoutLength = 30e3; // 30seconds

//Route "console.log()" calls from within the Page context to the main Phantom context (i.e. current "this")
page.onConsoleMessage = function(msg) {
  if(msg === '.' || msg === 'F'){
    // seems evil to write this to stderr but I couldn't make it flush sdtout reliably
    fs.write( '/dev/stderr', msg, 'w' );
  } else {
    console.log(msg);
  }
};

page.viewportSize = { width: 800, height: 600 }

page.open(url, function(status){
  if (status !== "success") {
    console.log("Unable to access network: " + status);
    phantom.exit(1);
  } else {
    page.evaluate(addLogging);
    var interval = setInterval(function() {
      if (timeoutLength < (+new Date() - lastTestCountChange)){
        console.log('');
        console.log('Test timeout. Aborting.');
        clearInterval(interval);
        phantom.exit(1);
      } else if (finished()) {
        clearInterval(interval);
        onfinishedTests();
      }
    }, 500);
  }
});

setInterval(function(){
  var testCount = page.evaluate(function(){
    return window.lastTestStarted;
  });
  if(testCount !== lastTestCount){
    lastTestCount = testCount;
    lastTestCountChange = +new Date();
  }
}, 250);


function finished() {
  return page.evaluate(function(){
    return !!window.qunitDone;
  });
};

function onfinishedTests() {
  var output = page.evaluate(function() {
      return JSON.stringify(window.qunitDone);
  });
  phantom.exit(JSON.parse(output).failed > 0 ? 1 : 0);
};

function addLogging() {
  var current_test_assertions = [];
  var module;

  window.testCount = 0;

  QUnit.moduleStart = function(context) {
    module = context.name;
  };

  QUnit.testStart = function(){
    window.testCount = window.testCount + 1;
  };

  QUnit.testDone = function(result) {
    var name = module + ': ' + result.name;
    var i;

    if (result.failed) {
      console.log('F');

      // This will force a newline so we don't write at the end of a row of dots
      console.log('');
      console.log('Assertion Failed: ' + name);

      for (i = 0; i < current_test_assertions.length; i++) {
        console.log('    ' + current_test_assertions[i]);
      }
    } else {
      console.log('.');
    }

    current_test_assertions = [];
  };

  QUnit.log = function(details) {
    var response;

    if (details.result) {
      return;
    }

    response = details.message || '';

    if (typeof details.expected !== 'undefined') {
      if (response) {
        response += ', ';
      }

      response += 'expected: ' + details.expected + ', but was: ' + details.actual;
    }

    current_test_assertions.push('Failed assertion: ' + response);
  };

  QUnit.done = function(result){
    // This will force a newline so we don't write at the end of a row of dots
    console.log('');
    console.log('Took ' + result.runtime +  'ms to run ' + result.total + ' tests. ' + result.passed + ' passed, ' + result.failed + ' failed.');
    window.qunitDone = result;
  };
}
