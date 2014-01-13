(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var adminEditionsForm = {
    init: function init(params) {
      this.$form = $(params.selector);
      this.rightToLeftLocales = params.right_to_left_locales;

      this.showChangeNotesIfMajorChange();
      this.showFormatAdviceForSelectedSubtype();
      this.setupNonEnglishSupport();

      GOVUK.formChangeProtection.init($('#edit_edition'), 'You have unsaved changes that will be lost if you leave this page.');
    },

    showChangeNotesIfMajorChange: function showChangeNotesIfMajorChange() {
      var $fieldset                  = $('.js-change-notes', this.$form);
      var $radio_buttons             = $('input[type=radio]', $fieldset);
      var $minor_change_radio_button = $('#edition_minor_change_true', $fieldset);
      var $change_notes_section      = $('.js-change-notes-section', $fieldset);

      $radio_buttons.change(showOrHideChangeNotes);
      showOrHideChangeNotes();

      function showOrHideChangeNotes() {
        if ($minor_change_radio_button.attr('checked')){
          $change_notes_section.slideUp(200);
        }
        else {
          $change_notes_section.slideDown(200);
        }
      }
    },

    showFormatAdviceForSelectedSubtype: function showFormatAdviceForSelectedSubtype() {
      var $subtypeFields = $('.subtype', this.$form).filter('select');

      if ($subtypeFields.length < 1) { return; }

      $subtypeFields.change(function() {
        var $field = $(this);
        var $container = $field.parent();
        var formatAdviceMap = $field.data('format-advice');

        $container.find('.govspeak').remove();

        var adviceText = formatAdviceMap[$field.val()];
        if (adviceText) {
          var adviceHTML = '<strong class="govspeak">Use this subformat for…</strong> '+adviceText;
          $container.append(adviceHTML);
        }
      }).change();
    },

    setupNonEnglishSupport: function setupNonEnglishSupport() {
      if ( !this.$form.hasClass('js-supports-non-english') ) return;

      var $form = this.$form;

      $().ready(function() {
        // hide locale fieldsets
        var $localeInput = $(this).find('#edition_locale');
        var $fieldset = $localeInput.parent('fieldset');
        $fieldset.hide();

        // add link for changing the default locale
        var $revealLink = $('<a href=# class="foreign-language-only">Designate as a foreign language only document</a>');
        $revealLink.insertBefore($fieldset);
        $revealLink.on('click', function () {
          // reveal the locale selector
          $(this).hide();
          $fieldset.show();
        });

        // add link to cancel and reset back to the default locale
        var $resetLink = $('<a href=# class="cancel-foreign-language-only">cancel</a>');
        $resetLink.insertAfter($localeInput);
        $resetLink.on('click', function () {
          // hide the fieldset and reset the locale selector
          $fieldset.hide();
          $revealLink.show();
          $localeInput.val('');
          $form.find('fieldset').removeClass('right-to-left');
        });

        // setup observer to apply right-to-left classes as appropriate
        $('#edition_locale').change(function () {
          if ( $.inArray($(this).val(), GOVUK.adminEditionsForm.rightToLeftLocales) > -1) {
            $form.find('fieldset').addClass('right-to-left');
          } else {
            $form.find('fieldset').removeClass('right-to-left');
          }
        });
      })

    }
  }

  window.GOVUK.adminEditionsForm = adminEditionsForm;
})();
