module("Making the Govspeak help dynamic", {
  setup: function() {
    var textarea = $('<textarea id="blah"># preview this</textarea>');
    var helpLink = this.helpLink = $('<a class="govspeak_help" href="#">help</a>')
    var label = $('<label for="blah"></label>');
    var helpContent = $('<section id="govspeak_help"></section>');
    label.append(helpLink);
    $('#qunit-fixture').append(textarea);
    $('#qunit-fixture').append(label);
    $('#qunit-fixture').append(helpContent);
    textarea.enableGovspeakHelp();
  }
});

test("should hide the help content", function() {
  ok(!$("#govspeak_help").is(":visible"));
})

test("should show the help content when clicking the link", function() {
  this.helpLink.click();
  ok($("#govspeak_help").is(":visible"));
})