(function ($) {
  var _enableMultipleFileUploads = function() {
    $(this).delegate("input[type=file]:last", "change", function() {
      var clone = $(this).parent().clone();
      clone.children("input").each(function(i, el) {
        var id = parseInt($(el).attr("id").match(/_(\d)_/)[1]);
        var newId = id + 1;
        $(el).attr("id", $(el).attr("id").replace("_"+id+"_", "_"+newId+"_"));
        $(el).attr("name", $(el).attr("name").replace("["+id+"]", "["+newId+"]"));
      });
      $(this).parent().after(clone);
    });
  }

  $.fn.extend({
    enableMultipleFileUploads: _enableMultipleFileUploads
  });
})(jQuery);

jQuery(function($) {
  $(".multiple_file_uploads").enableMultipleFileUploads();
})