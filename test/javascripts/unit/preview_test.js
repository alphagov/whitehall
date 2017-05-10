module("Previewing contents of a textarea", {
  setup: function() {
    var textarea = $('<textarea id="blah"># preview this</textarea>');
    var label = $('<label for="blah"></label>');
    var image_inputs = $('<fieldset class="images">' +
      '<div class="image lead"><input name="edition[images_attributes][0][id]" type="hidden" value="1"></div>' +
      '<div class="image"><input name="edition[images_attributes][1][id]" type="hidden" value="2"></div>' +
      '</fieldset>');
    var attachment_inputs = $('<fieldset class="attachments">' +
      '<input id="edition_edition_attachments_attributes_0_attachment_attributes_id" name="edition[edition_attachments_attributes][0][attachment_attributes][id]" type="hidden" value="276">' +
      '</fieldset>');
    var alternative_format_provider_select =$('<select id="edition_alternative_format_provider_id">' +
      '<option value="1">Ministry of Song</option>' +
      '<option value="2" selected="selected">Ministry of Silly Walks</option>' +
      '</select>');
    $('#qunit-fixture').append(textarea);
    $('#qunit-fixture').append(label);
    $('#qunit-fixture').append(image_inputs);
    $('#qunit-fixture').append(attachment_inputs);
    $('#qunit-fixture').append(alternative_format_provider_select);
    textarea.enablePreview();

    this.stubbingPreviewAjax = function(callback, preventResponse) {
      var ajax = this.spy(jQuery, "ajax");
      var server = this.sandbox.useFakeServer();
      server.respondWith("POST", "/government/admin/preview",
                         [200, { "Content-Type": "text/html" },
                          '<h1>preview this</h1>']);
      callback();
      if (!preventResponse) {
        server.respond();
      }
      return ajax
    }
  }
});

test("should post the textarea value to the preview controller", function() {
  var ajax = this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  })

  sinon.assert.calledOnce(ajax);
  if (jQuery.ajax.getCall(0)) {
    var callParams = jQuery.ajax.getCall(0).args[0];
    equal(callParams.url, "/government/admin/preview");
    equal(callParams.data.body, "# preview this");
  }
});

test("should include the authenticity token in the posted data", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  })

  var callParams = jQuery.ajax.getCall(0).args[0];
  equal(callParams.data.authenticity_token, $("meta[name-csrf-token]").val());
})

test("should include ids of any persisted images", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  })

  var callParams = jQuery.ajax.getCall(0).args[0];
  deepEqual(callParams.data.image_ids, ["1", "2"]);
});

test("should include ids of any persisted attachments", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  })

  var callParams = jQuery.ajax.getCall(0).args[0];
  deepEqual(callParams.data.attachment_ids, ["276"]);
});

test("should include alternative_format_provider_id", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  })

  var callParams = jQuery.ajax.getCall(0).args[0];
  deepEqual(callParams.data.alternative_format_provider_id, "2");
});

test("should indicate that the preview is loading", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  }, true)

  ok($(".preview-controls .loading").is(":visible"));
})

test("should hide the text area", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  });

  var editor = $("textarea");
  ok(!editor.is(":visible"));
})

test("should show the preview contents when the server responds", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  });

  var previewForTextArea = $("#blah_preview");
  ok(previewForTextArea.is(":visible"));
})

test("should hide the loading indicator when the server responds", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  });

  ok(!$(".preview-controls .loading").is(":visible"));
})

test("should show the rendered preview when the server responds", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  });

  var previewForTextArea = $("#blah_preview");
  equal(previewForTextArea.html(), "<h1>preview this</h1>");
})

test("should hide the preview contents when clicking edit again", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  });

  $("a.show-editor").click();

  var previewForTextArea = $("textarea").parent().parent().find(".preview");
  ok(!previewForTextArea.is(":visible"));
})

test("should show the editor when clicking edit again", function() {
  this.stubbingPreviewAjax(function() {
    $("a.show-preview").click();
  });

  $("a.show-editor").click();

  var editor = $("textarea").parent();
  ok(editor.is(":visible"));
})

test("should show an alert if the response was not 200", function() {
  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();
  server.respondWith("POST", "/government/admin/preview",
                     [403, { "Content-Type": "text/html" },
                      'Some error message']);

  var alertStub = this.stub(window, "alert", function(msg) { return false; } );

  $("a.show-preview").click();
  server.respond();

  equal(1, alertStub.callCount, "showing preview should have invoked alert one time");
  equal("Some error message", alertStub.getCall(0).args[0], "alert should have shown error from server");
})
