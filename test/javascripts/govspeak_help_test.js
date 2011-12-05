module("Making the Govspeak help dynamic", {
  addMasterHelpSection: function() {
    var helpContent = $('<section id="govspeak_help"></section>');
    $('#qunit-fixture').append(helpContent);
  },
  addTextArea: function(fieldsetID) {
    var textareaID = fieldsetID + "_textarea";
    var fieldset = this.fieldset = $('<fieldset id="' + fieldsetID + '"></fieldset>');
    var helpLink = $('<a class="govspeak_help" href="#">help</a>');
    var label = $('<label for="' + textareaID + '"></label>');
    var textarea = $('<textarea id="' + textareaID + '"></textarea>');
    label.append(helpLink);
    fieldset.append(label);
    fieldset.append(textarea);
    $('#qunit-fixture').append(fieldset);
    return textarea;
  },
  setup: function() {
    this.fieldsetID = "fieldset_1";
    this.textarea = this.addTextArea(this.fieldsetID);
    this.addMasterHelpSection();
    this.textarea.enableGovspeakHelp();
  }
});

test("should hide the master help section", function() {
  ok(!$("#govspeak_help").is(":visible"));
});

test("should add a hidden copy of the help content to the fieldset containing the textarea", function() {
  var help = $('section.govspeak_help', this.fieldset);
  equal(help.length, 1);
  ok(!help.is(":visible"));
});

test("should show the help content associated with the textarea when clicking the link", function() {
  var help = $('section.govspeak_help', this.fieldset);
  var helpLink = $('a.govspeak_help', this.fieldset);
  helpLink.click();
  ok(help.is(":visible"));
});

test("should allow multiple formatting help sections on the same page", function() {
  var fieldsetID = "fieldset_2";
  var textarea = this.addTextArea(fieldsetID);
  textarea.enableGovspeakHelp();
  var fieldset = $('#' + fieldsetID);
  var help = $('section.govspeak_help', fieldset);
  var helpLink = $('a.govspeak_help', fieldset);
  helpLink.click();
  ok(help.is(":visible"));
});