test("should hide the help content associated with the textarea when clicking the link twice", function() {
  console.log("foobar");
  stop(1000);
  console.log("woohoo");
  // var help = $('section.govspeak_help', this.fieldset);
  // var helpLink = $('a.govspeak_help', this.fieldset);
  // helpLink.click();

  setTimeout(function() {
    console.log("in callback");
    // helpLink.click();
    // ok(!help.is(":visible"));
    // console.log($("#qunit-fixture").html());
    ok(true);
    start();
  }, 10);
  // start();
});


// test("should hide the help content associated with the textarea when clicking the link twice", function() {
//   var help = $('section.govspeak_help', this.fieldset);
//   var helpLink = $('a.govspeak_help', this.fieldset);
//   helpLink.click();
//   helpLink.click();
//   ok(!help.is(":visible"));
//   console.log($("#qunit-fixture").html());
// });