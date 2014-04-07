(function ($) {
  var _enablePreview = function() {
    $(this).each(function() {
      var textarea = $(this);
      var preview = $("<div id='" + textarea.attr("id") + "_preview'></div>");
      var preview_controls = $("<span class='preview-controls'></span>");
      var preview_link = $("<a href='#' class='show-preview'>preview</a>");
      var edit_link = $("<a href='#' class='show-editor'>continue editing</a>");
      var loading_indicator = $("<span class='loading'>please wait...</span>");
      var label = $("label[for=" + textarea.attr("id") +"]");

      preview_controls.append(preview_link);
      preview_controls.append(edit_link);
      preview_controls.append(loading_indicator);
      label.append(preview_controls);
      label.after(preview);

      var showEditor = function() {
        preview.empty();
        edit_link.hide();
        textarea.show();
        preview_link.show();
        loading_indicator.hide();
        $(document).trigger("govuk.WordsToAvoidGuide.enable");
      }

      var showPreview = function() {
        $(document).trigger("govuk.WordsToAvoidGuide.disable");
        textarea.hide();
        preview_link.hide();
        preview.enhanceYoutubeVideoLinks();
        preview.show();
        edit_link.show();
      };

      var imageNodes = function() {
        return $("fieldset.images input[type=hidden][name^='edition[images_attributes]'][name$='[id]']");
      };

      var attachmentNodes = function() {
        var selectors = [
          "fieldset.attachments input[type=hidden][name^='edition[edition_attachments_attributes]'][name$='[attachment_attributes][id]']",
          "fieldset.attachments input[type=hidden][name^='supporting_page[supporting_page_attachments_attributes]'][name$='[attachment_attributes][id]']",
          "fieldset.attachments input[type=hidden][name^='corporate_information_page[corporate_information_page_attachments_attributes]'][name$='[attachment_attributes][id]']"
        ]
        return $(selectors.join(','));
      };

      var imageIds = function() {
        return $.map(imageNodes(), function(node) {
          return $(node).val();
        });
      };

      var attachmentIds = function() {
        return $.map(attachmentNodes(), function(node) {
          return $(node).val();
        });
      };

      var alternativeFormatProviderId = function() {
        return $('select#edition_alternative_format_provider_id').val();
      };
      showEditor();

      preview_link.click(function() {
        var params = {
          body: textarea.val(),
          authenticity_token: $("meta[name=csrf-token]").attr('content'),
          image_ids: imageIds(),
          attachment_ids: attachmentIds(),
          alternative_format_provider_id: alternativeFormatProviderId()
        };
        loading_indicator.show();
        preview_link.hide();
        $.ajax({
          type: 'POST',
          url: "/government/admin/preview",
          data: params,
          success: function(data) {
            loading_indicator.hide();
            preview.html(data);
            showPreview();
            govspeakBarcharts();
          },
          error: function(data) {
            alert(data.responseText);
            showEditor();
          }
        })
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
