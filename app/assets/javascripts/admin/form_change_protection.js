(function () {
  "use strict";
  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var formChangeProtection = {
    init: function (form, message) {
      this.$form = $(form);
      this.message = message;
      this.initialState = this.serialisedFormValues();

      this.preventLossOfUnsavedChanges();
    },

    serialisedFormValues: function () {
      var formdata = this.$form.serialize();

      this.$form.find('input[type=file]').each(function () {
        formdata = formdata + $(this).val();
      });

      return formdata;
    },

    alertIfUnsavedChanges: function () {
      var current = formChangeProtection.serialisedFormValues();

      if (current != formChangeProtection.initialState) {
        return formChangeProtection.message;
      }
    },

    preventLossOfUnsavedChanges: function () {
      $(window).bind('beforeunload', this.alertIfUnsavedChanges);
      // unbind when the form is submitted to stop the alert
      this.$form.bind('submit', function() {
        $(window).unbind('beforeunload');
      });
    }
  }

  root.GOVUK.formChangeProtection = formChangeProtection;
}).call(this);
