(function ($) {
  var _setupNonEnglishSupport = function () {
    $(this).each(function() {
      var $localeInput = $(this).find('#edition_locale');
      var $fieldset = $localeInput.parent('fieldset');
      $fieldset.hide();

      var $revealLink = $('<a href=# class="foreign-language-only">Foreign language only document</a>');
      $revealLink.insertBefore($fieldset);
      $revealLink.on('click', function () {
        // reveal the locale selector
        $(this).hide();
        $fieldset.show();
      });

      var $resetLink = $('<a href=# class="cancel-foreign-language-only">cancel</a>');
      $resetLink.insertAfter($localeInput);
      $resetLink.on('click', function () {
        // hide the fieldset and reset the locale selector
        $fieldset.hide();
        $revealLink.show();
        $localeInput.val('');
      });
    });
  }

  $.fn.extend({
    setupNonEnglishSupport: _setupNonEnglishSupport
  });
})(jQuery);

jQuery(function($) {
  $("form.supports-non-english").setupNonEnglishSupport();
})
