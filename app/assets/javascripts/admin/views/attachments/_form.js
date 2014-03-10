(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  var AdminAttachmentsForm = {
    init: function init(params) {
      this.$form = $(params.selector);
      this.rightToLeftLocales = params.right_to_left_locales;

      this.setupLocaleSwitching();
      this.showMaunalNumberingNotesIfSelected();
    },

    setupLocaleSwitching: function setupLocaleSwitching() {
      var $form = this.$form;
      $form.find('#attachment_locale').change(function () {
        if ( $.inArray($(this).val(), GOVUK.AdminAttachmentsForm.rightToLeftLocales) > -1) {
          $form.find('fieldset').addClass('right-to-left');
        } else {
          $form.find('fieldset').removeClass('right-to-left');
        }
      });
    },

    showMaunalNumberingNotesIfSelected: function showMaunalNumberingNotesIfSelected() {
      $('#attachment_manually_numbered_headings').change(function () {
        $('.js-manual-numbering-help').toggle($(this).is(':checked'));
      }).change();
    }
  }

  GOVUK.AdminAttachmentsForm = AdminAttachmentsForm;
}());
