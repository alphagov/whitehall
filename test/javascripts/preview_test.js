module("Previewing contents of a textarea", {
  setup: function() {
    var textarea = $('<textarea># preview this</textarea>');
    $('#qunit-fixture').append(textarea);
    textarea.enablePreview();

    this.stubbingAjax = function(callback) {
      var ajax = this.spy(jQuery, "ajax");
      callback();
      return ajax
    }

    this.stubbingServer = function(callback) {
      var server = this.sandbox.useFakeServer();
      server.respondWith("POST", "/admin/preview",
                         [200, { "Content-Type": "text/html" },
                          '<h1>preview this</h1>']);
      callback();
      server.respond();
    }
  }
});

test("should post the textarea value to the preview controller", function() {
  var ajax = this.stubbingAjax(function() {
    $("a.show-preview").click();
  })

  sinon.assert.calledOnce(ajax);
  var callParams = jQuery.ajax.getCall(0).args[0];
  equals(callParams.url, "/admin/preview");
  equals(callParams.data.body, "# preview this");
});

test("should include the authenticity token in the posted data", function() {
  var ajax = this.stubbingAjax(function() {
    $("a.show-preview").click();
  })

  var callParams = jQuery.ajax.getCall(0).args[0];
  equals(callParams.data.authenticity_token, $("meta[name-csrf-token]").val());
})

test("should hide the text area", function() {
  this.stubbingServer(function() {
    $("a.show-preview").click();
  });

  var editor = $("textarea").parent();
  ok(!editor.is(":visible"));
})

test("should show the preview contents when the server responds", function() {
  this.stubbingServer(function() {
    $("a.show-preview").click();
  });

  var previewForTextArea = $("textarea").parent().parent().find(".preview");
  ok(previewForTextArea.is(":visible"));
})

test("should show the rendered preview when the server responds", function() {
  this.stubbingServer(function() {
    $("a.show-preview").click();
  });

  var previewForTextArea = $("textarea").parent().parent().find(".preview");
  equals(previewForTextArea.find(".preview-content").html(), "<h1>preview this</h1>");
})

test("should hide the preview contents when clicking edit again", function() {
  this.stubbingServer(function() {
    $("a.show-preview").click();
  });

  $("a.hide-preview").click();

  var previewForTextArea = $("textarea").parent().parent().find(".preview");
  ok(!previewForTextArea.is(":visible"));
})

test("should show the editor when clicking edit again", function() {
  this.stubbingServer(function() {
    $("a.show-preview").click();
  });

  $("a.hide-preview").click();

  var editor = $("textarea").parent();
  ok(editor.is(":visible"));
})