(function ($) {
  var _enableMultipleFileUploads = function() {
    $(this).each(function() {
      var elementId = $(this).attr("id");
      if (elementId == undefined) {
        console.log("Element must have an ID; multiple file upload behaviour has not been enabled.");
        return;
      }
      var lastFileInputSelector = ".well:last-child input[type=file]";
      $(this).delegate(lastFileInputSelector, "click", function() {
        var clone = $(this).parents(".file_upload").clone();
        var referenceInput = clone.children("input:first")[0];
        var id = parseInt($(referenceInput).attr("id").match(/_(\d+)_/)[1]);
        var newId = id + 1;
        clone.find(".field_with_errors *").unwrap();
        clone.children("label").each(function(i, el) {
          $(el).attr("for", $(el).attr("for").replace("_"+id+"_", "_"+newId+"_"));
        });
        clone.children("input,textarea").each(function(i, el) {
          if ($(el).attr('id')) {
            $(el).attr("id", $(el).attr("id").replace("_"+id+"_", "_"+newId+"_"));
          }
          $(el).attr("name", $(el).attr("name").replace("["+id+"]", "["+newId+"]"));
        });
        clone.children("input").val("");
        clone.children(".already_uploaded").text("");
        $(this).parents(".file_upload").after(clone);
      });
    })
  }

  $.fn.extend({
    enableMultipleFileUploads: _enableMultipleFileUploads
  });
})(jQuery);

jQuery(function($) {
  $(".multiple_file_uploads").enableMultipleFileUploads();
})
