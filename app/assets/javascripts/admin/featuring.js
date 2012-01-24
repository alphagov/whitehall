(function ($) {
  var _toggleUpdateImageForm = function() {
    $(this).each(function() {
      var form = $(this);
      var form_controls = $("<div class='edit_image_controls'></div>");
      var edit_link = $("<a href='#' class='edit_update_image'>edit image</a>");
      var hide_link = $("<a href='#' class='hide_update_image'>hide image editor</a>");

      form_controls.append(edit_link);
      form_controls.append(hide_link);
      form.before(form_controls);

      var showForm = function() {
        edit_link.hide();
        hide_link.show();
        form.show();
      }

      var hideForm = function() {
        edit_link.show();
        hide_link.hide();
        form.hide();
      }

      hideForm();

      edit_link.click(function() {
        showForm();
      });

      hide_link.click(function() {
        hideForm();
      });
    })
  }

  $.fn.extend({
    toggleUpdateImageForm: _toggleUpdateImageForm
  });
})(jQuery);

jQuery(function($) {
  $("form.update_image").toggleUpdateImageForm();
})