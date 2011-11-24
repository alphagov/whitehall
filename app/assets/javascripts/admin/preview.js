(function ($) {
  var _enablePreview = function() {
    $(this).each(function() {
      var textarea = $(this);
      var preview = $("<div id='" + textarea.attr("id") + "_preview'></div>");
      var preview_controls = $("<span class='preview-controls'></span>");
      var preview_link = $("<a href='#' class='show-preview'>preview</a>");
      var edit_link = $("<a href='#' class='show-editor'>edit</a>");
      var loading_indicator = $("<span class='loading'>please wait...</span>");
      var label = $("label[for=" + textarea.attr("id") +"]");

      textarea.after(preview);
      preview_controls.append(preview_link);
      preview_controls.append(edit_link);
      preview_controls.append(loading_indicator);
      label.append(preview_controls);

      var showEditor = function() {
        preview.hide();
        edit_link.hide();
        textarea.show();
        preview_link.show();
        loading_indicator.hide();
      }

      var showPreview = function() {
        textarea.hide();
        preview_link.hide();
        preview.show();
        edit_link.show();
      }

      showEditor();

      preview_link.click(function() {
        params = {
          body: textarea.val(),
          authenticity_token: $("meta[name=csrf-token]").attr('content')
        }
        loading_indicator.show();
        preview_link.hide();
        $.post("/admin/preview", params, function(data) {
          loading_indicator.hide();
          preview.html(data);
          showPreview();
        });
        return false;
      })

      edit_link.click(function() {
        showEditor();
        return false;
      })
    })
  }

  $.fn.extend({
    enablePreview: _enablePreview
  });
})(jQuery);

jQuery(function($) {
  $("textarea.previewable").enablePreview();
})