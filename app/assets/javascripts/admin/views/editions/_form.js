(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var editionForm = {
    init: function init(params) {
      this.$form = $(params.selector);

      this.showChangeNotesIfMajorChange();
      this.showFormatAdviceForSelectedSubtype();
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
    }
  }

  window.GOVUK.editionForm = editionForm;
})();
