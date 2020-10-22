/* global govspeakBarcharts */
(function ($) {
  var _enablePreview = function () {
    $(this).each(function () {
      var textarea = $(this)
      var preview = $("<div id='" + textarea.attr('id') + "_preview'></div>")
      var previewControls = $("<span class='preview-controls'></span>")
      var previewLink = $("<a href='#' class='show-preview'>preview</a>")
      var editLink = $("<a href='#' class='show-editor'>continue editing</a>")
      var loadingIndicator = $("<span class='loading'>please wait...</span>")
      var label = $('label[for=' + textarea.attr('id') + ']')

      previewControls.append(previewLink)
      previewControls.append(editLink)
      previewControls.append(loadingIndicator)
      label.append(previewControls)
      label.after(preview)

      var showEditor = function () {
        preview.empty()
        editLink.hide()
        textarea.show()
        previewLink.show()
        loadingIndicator.hide()
        $(document).trigger('govuk.WordsToAvoidGuide.enable')
      }

      var showPreview = function () {
        $(document).trigger('govuk.WordsToAvoidGuide.disable')
        textarea.hide()
        previewLink.hide()
        preview.enhanceYoutubeVideoLinks()
        preview.show()
        editLink.show()
      }

      var imageNodes = function () {
        return $("fieldset.images input[type=hidden][name^='edition[images_attributes]'][name$='[id]']")
      }

      var attachmentNodes = function () {
        var selectors = [
          "fieldset.attachments input[type=hidden][name^='edition[edition_attachments_attributes]'][name$='[attachment_attributes][id]']",
          "fieldset.attachments input[type=hidden][name^='corporate_information_page[corporate_information_page_attachments_attributes]'][name$='[attachment_attributes][id]']"
        ]
        return $(selectors.join(','))
      }

      var imageIds = function () {
        return $.map(imageNodes(), function (node) {
          return $(node).val()
        })
      }

      var attachmentIds = function () {
        return $.map(attachmentNodes(), function (node) {
          return $(node).val()
        })
      }

      var alternativeFormatProviderId = function () {
        return $('select#edition_alternative_format_provider_id').val()
      }
      showEditor()

      previewLink.click(function () {
        var params = {
          body: textarea.val(),
          authenticity_token: $('meta[name=csrf-token]').attr('content'),
          image_ids: imageIds(),
          attachment_ids: attachmentIds(),
          alternative_format_provider_id: alternativeFormatProviderId()
        }
        loadingIndicator.show()
        previewLink.hide()
        $.ajax({
          type: 'POST',
          url: '/government/admin/preview',
          data: params,
          success: function (data) {
            loadingIndicator.hide()
            preview.html(data)
            showPreview()
            govspeakBarcharts()
          },
          error: function (data) {
            alert(data.responseText)
            showEditor()
          }
        })
        return false
      })

      editLink.click(function () {
        showEditor()
        return false
      })
    })
  }

  $.fn.extend({
    enablePreview: _enablePreview
  })
})(jQuery)

jQuery(function ($) {
  $('textarea.previewable').enablePreview()
})
