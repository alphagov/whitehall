module("No change note label or field present", {
  setup: function() {
    this.publishingForm = $("<form />");

    $("#qunit-fixture").append(this.publishingForm);
    this.publishingForm.enableChangeNoteHighlighting();
  }
});

test("should not hide form", function() {
  ok($(this.publishingForm).is(":visible"));
});

module("Change note label and field present with publish button", {
  setup: function() {
    this.publishingForm = $("<form />");
    this.changeNoteLabel = $("<label for='edition_change_note' />")
    this.changeNoteTextarea = $("<textarea id='edition_change_note' />");
    this.publishingForm.append(this.changeNoteLabel);
    this.publishingForm.append(this.changeNoteTextarea);
    this.publishingForm.append("<input type='submit' value='Publish'/>");

    $("#qunit-fixture").append(this.publishingForm);
    this.publishingForm.enableChangeNoteHighlighting();
  }
});

test("should hide form", function() {
  ok($(this.publishingForm).is(":hidden"));
});

test("should insert a publish button link before the form", function() {
  equal(this.publishingForm.prev("a.button[href='#edition_publishing']").text(), "Publish");
});

test("should hide publish button when the publish button link is clicked", function() {
  this.publishingForm.prev("a.button").click();
  ok(this.publishingForm.prev("a.button").is(":hidden"));
});

test("should wrap change note label in validation error class when the publish button link is clicked", function() {
  this.publishingForm.prev("a.button").click();
  ok(this.changeNoteLabel.parents().hasClass("field_with_errors"));
});

test("should wrap change note textarea in validation error class when the publish button link is clicked", function() {
  this.publishingForm.prev("a.button").click();
  ok(this.changeNoteTextarea.parents().hasClass("field_with_errors"));
});

test("should show form when the publish button link is clicked", function() {
  this.publishingForm.prev("a.button").click();
  ok($(this.publishingForm).is(":visible"));
});

module("Change note label and field present with force publish button", {
  setup: function() {
    this.publishingForm = $("<form />");
    this.changeNoteLabel = $("<label for='edition_change_note' />")
    this.changeNoteTextarea = $("<textarea id='edition_change_note' />");
    this.publishingForm.append(this.changeNoteLabel);
    this.publishingForm.append(this.changeNoteTextarea);
    this.publishingForm.append("<input type='submit' value='Force publish'/>");

    $("#qunit-fixture").append(this.publishingForm);
    this.publishingForm.enableChangeNoteHighlighting();
  }
});

test("should insert a force publish button link before the form", function() {
  equal(this.publishingForm.prev("a.button[href='#edition_publishing']").text(), "Force publish");
});
