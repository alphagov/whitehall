(function ($) {
  var _enablePreview = function() {
    var container = $("<div class='previewable-editor'></div>");
    var editor = $("<div class='editor'></div>");
    var preview_link = $("<a href='#' class='show-preview'>preview</a>");
    var textarea = $(this);

    textarea.replaceWith(container);

    editor.append(preview_link);
    editor.append(textarea);

    var preview = $("<div class='preview'></div>")
    var preview_content = $("<div class='preview-content'></div>");
    var edit_link = $("<a href='#' class='hide-preview'>edit</a>")
    preview.append(edit_link);
    preview.append(preview_content);

    container.append(editor);
    container.append(preview);
    preview.hide();

    preview_link.click(function() {
      params = {
        body: textarea.val(),
        authenticity_token: $("meta[name=csrf-token]").attr('content')
      }
      $.post("/admin/preview", params, function(data) {
        preview_content.html(data);
        editor.hide();
        preview.show();
      });
      return false;
    })

    edit_link.click(function() {
      preview.hide();
      editor.show();
      return false;
    })
  }

  $.fn.extend({
    enablePreview: _enablePreview
  });
})(jQuery);

jQuery(function() {
  jQuery("textarea.previewable").enablePreview();
})