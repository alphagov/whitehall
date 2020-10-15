(function ($) {
  var _toggleUpdateImageForm = function () {
    $(this).each(function () {
      var form = $(this)
      var formControls = $("<div class='edit_image_controls'></div>")
      var editLink = $("<a href='#' class='edit_update_image'>edit image</a>")
      var hideLink = $("<a href='#' class='hide_update_image'>hide image editor</a>")

      formControls.append(editLink)
      formControls.append(hideLink)
      form.before(formControls)

      var showForm = function () {
        editLink.hide()
        hideLink.show()
        form.show()
      }

      var hideForm = function () {
        editLink.show()
        hideLink.hide()
        form.hide()
      }

      hideForm()

      editLink.click(function () {
        showForm()
      })

      hideLink.click(function () {
        hideForm()
      })
    })
  }

  $.fn.extend({
    toggleUpdateImageForm: _toggleUpdateImageForm
  })
})(jQuery)

jQuery(function ($) {
  $('form.update_image').toggleUpdateImageForm()
})
