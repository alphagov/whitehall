module("Uploading multiple files", {
  setup: function() {
    this.fieldset = $('<fieldset id="attachment_fields" class="multiple_file_uploads"></fieldset>');
    var file_upload = $('<div class="file_upload well"></div>');
    this.first_input = $('<input id="edition_edition_attachments_attributes_0_attachment_attributes_file" name="edition[edition_attachments_attributes][0][attachment_attributes][file]" type="file" />');

    file_upload.append('<label for="edition_edition_attachments_attributes_0_attachment_attributes_title">Title</label>');
    file_upload.append('<input id="edition_edition_attachments_attributes_0_attachment_attributes_title" name="edition[edition_attachments_attributes][0][attachment_attributes][title]" size="30" type="text" />');
    file_upload.append('<label for="edition_edition_attachments_attributes_0_attachment_attributes_caption">Caption</label>');
    file_upload.append('<textarea id="edition_edition_attachments_attributes_0_attachment_attributes_caption" name="edition[edition_attachments_attributes][0][attachment_attributes][caption]"></textarea>');
    file_upload.append('<label for="edition_edition_attachments_attributes_0_attachment_attributes_file">File</label>');
    file_upload.append(this.first_input);
    file_upload.append('<label for="edition_edition_attachments_attributes_0_attachment_attributes_accessible"><input id="edition_edition_attachments_attributes_0_attachment_attributes_accessible" name="edition[edition_attachments_attributes][0][attachment_attributes][accessible]" type="checkbox" value="1"> Acccessible</label>');
    file_upload.append('<input id="edition_edition_attachments_attributes_0_attachment_attributes_file_cache" name="edition[edition_attachments_attributes][0][attachment_attributes][file_cache]" type="hidden" />');

    this.fieldset.append(file_upload);
    $('#qunit-fixture').append(this.fieldset);
    this.fieldset.enableMultipleFileUploads();
  }
});

var fireClickEventOnLastFileInputOf = function(fieldset) {
  fieldset.find("input[type=file]:last").click();
}

test("should add a new file input when a file is selected", function() {
  this.first_input.click();
  equal(this.fieldset.children(".file_upload").length, 2);
});

test("should not add a new file input when a selected file is clicked", function() {
  this.first_input.click();
  this.first_input.click();
  equal(this.fieldset.children(".file_upload").length, 2);
});

test("should continue adding new inputs as new files are selected", function() {
  for(i = 0; i < 10; i++) {
    fireClickEventOnLastFileInputOf(this.fieldset);
  }
  equal(this.fieldset.children(".file_upload").length, 11);

  fireClickEventOnLastFileInputOf(this.fieldset);
  equal(this.fieldset.children(".file_upload").length, 12);
});

test("should increment the referenced ID of the title label for each new set of inputs added", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  var latest_input = this.fieldset.find("label:contains('Title'):last");
  equal(latest_input.attr('for'), "edition_edition_attachments_attributes_1_attachment_attributes_title");

  fireClickEventOnLastFileInputOf(this.fieldset);
  latest_input = this.fieldset.find("label:contains('Title'):last");
  equal(latest_input.attr('for'), "edition_edition_attachments_attributes_2_attachment_attributes_title");
});

test("should increment the ID and name of the text input for each set of new inputs added", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  var latest_input = this.fieldset.find("input[type=text]:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_1_attachment_attributes_title");
  equal(latest_input.name, "edition[edition_attachments_attributes][1][attachment_attributes][title]");

  fireClickEventOnLastFileInputOf(this.fieldset);
  latest_input = this.fieldset.find("input[type=text]:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_2_attachment_attributes_title");
  equal(latest_input.name, "edition[edition_attachments_attributes][2][attachment_attributes][title]");
});

test("should increment the ID and name of the textareas for each set of new inputs added", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  var latest_input = this.fieldset.find("textarea:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_1_attachment_attributes_caption");
  equal(latest_input.name, "edition[edition_attachments_attributes][1][attachment_attributes][caption]");

  fireClickEventOnLastFileInputOf(this.fieldset);
  latest_input = this.fieldset.find("textarea:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_2_attachment_attributes_caption");
  equal(latest_input.name, "edition[edition_attachments_attributes][2][attachment_attributes][caption]");
});

test("should increment the ID and name of the checkboxes for each set of new inputs added", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  var latest_input = this.fieldset.find("input[type=checkbox]:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_1_attachment_attributes_accessible");
  equal(latest_input.name, "edition[edition_attachments_attributes][1][attachment_attributes][accessible]");

  fireClickEventOnLastFileInputOf(this.fieldset);
  latest_input = this.fieldset.find("input[type=checkbox]:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_2_attachment_attributes_accessible");
  equal(latest_input.name, "edition[edition_attachments_attributes][2][attachment_attributes][accessible]");
});

test("should increment the referenced ID of the file label for each set of new inputs added", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  var latest_input = this.fieldset.find("label:contains('File'):last");
  equal(latest_input.attr('for'), "edition_edition_attachments_attributes_1_attachment_attributes_file");

  fireClickEventOnLastFileInputOf(this.fieldset);
  latest_input = this.fieldset.find("label:contains('File'):last");
  equal(latest_input.attr('for'), "edition_edition_attachments_attributes_2_attachment_attributes_file");
});

test("should increment the ID and name of the file input for each set of new inputs added", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  var latest_input = this.fieldset.find("input[type=file]:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_1_attachment_attributes_file");
  equal(latest_input.name, "edition[edition_attachments_attributes][1][attachment_attributes][file]");

  fireClickEventOnLastFileInputOf(this.fieldset);
  latest_input = this.fieldset.find("input[type=file]:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_2_attachment_attributes_file");
  equal(latest_input.name, "edition[edition_attachments_attributes][2][attachment_attributes][file]");
});

test("should increment the ID and name of the hidden cache input for each set of new inputs added", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  var latest_input = this.fieldset.find("input[type=hidden]:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_1_attachment_attributes_file_cache");
  equal(latest_input.name, "edition[edition_attachments_attributes][1][attachment_attributes][file_cache]");

  fireClickEventOnLastFileInputOf(this.fieldset);
  latest_input = this.fieldset.find("input[type=hidden]:last")[0];
  equal(latest_input.id, "edition_edition_attachments_attributes_2_attachment_attributes_file_cache");
  equal(latest_input.name, "edition[edition_attachments_attributes][2][attachment_attributes][file_cache]");
});

test("should make the value of the text input blank for each set of new inputs added", function() {
  this.fieldset.find("input[type=text]:last").val("not-blank");
  fireClickEventOnLastFileInputOf(this.fieldset);
  var latest_input = this.fieldset.find("input[type=text]:last");
  equal(latest_input.val(), "");
});

test("should set the value of the hidden cache input to blank for each new input added", function() {
  $("input[type=hidden]:last").val("not-blank");
  fireClickEventOnLastFileInputOf(this.fieldset);
  var latest_input = this.fieldset.find("input[type=hidden]:last");
  equal(latest_input.val(), "");
});

test("should set the text of the already_uploaded element to blank for each new input added", function() {
  already_uploaded = $('<span class="already_uploaded">some-file.pdf already uploaded</span>');
  $("input[type=file]:last").after(already_uploaded);
  fireClickEventOnLastFileInputOf(this.fieldset);
  equal(this.fieldset.find(".already_uploaded").length, 2);
  equal(this.fieldset.find(".already_uploaded:last").text(), "");
});

module("Uploading multiple files after file field validation error", {
  setup: function() {
    this.fieldset = $('\
      <fieldset id="attachment_fields" class="multiple_file_uploads">\
        <div class="file_upload well">\
          <label for="edition_edition_attachments_attributes_0_attachment_attributes_title">Title</label>\
          <input id="edition_edition_attachments_attributes_0_attachment_attributes_title"\ name="edition[edition_attachments_attributes][0][attachment_attributes][title]" size="30" type="text" value="something" />\
          <div class="field_with_errors">\
            <label for="edition_edition_attachments_attributes_0_attachment_attributes_file">File</label>\
          </div>\
          <div class="field_with_errors">\
            <input id="edition_edition_attachments_attributes_0_attachment_attributes_file"\ name="edition[edition_attachments_attributes][0][attachment_attributes][file]" type="file" />\
          </div>\
          <input id="edition_edition_attachments_attributes_0_attachment_attributes_file_cache"\ name="edition[edition_attachments_attributes][0][attachment_attributes][file_cache]" type="hidden" />\
        </div>\
      </fieldset>\
    ');
    $('#qunit-fixture').append(this.fieldset);
    this.fieldset.enableMultipleFileUploads();
  }
});

test("should add a new file input when a file is selected", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  equal(this.fieldset.children(".file_upload").length, 2);
});

test("should copy the file label without error wrapper for each set of new inputs added", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  equal(this.fieldset.find("label:contains('File'):last").parent().hasClass("field_with_errors"), false);
  equal(this.fieldset.find(".field_with_errors label:contains('File')").length, 1);
});

test("should copy the file input without error wrapper for each set of new inputs added", function() {
  fireClickEventOnLastFileInputOf(this.fieldset);
  equal(this.fieldset.find("input[type=file]").length, 2);
  equal(this.fieldset.find(".field_with_errors input[type=file]").length, 1);
});
