(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var adminEditionsForm = {
    init: function init(params) {
      this.$form = $(params.selector);
      this.rightToLeftLocales = params.right_to_left_locales;

      this.showChangeNotesIfMajorChange();
      this.showFormatAdviceForSelectedSubtype();
      this.toggleLanguageSelect();
      this.toggleNonEnglishSupport();
      this.toggleFirstPublishedDate();

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
        if ($minor_change_radio_button.prop('checked')){
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

        $container.find('.subtype-format-advice').remove();

        var adviceText = formatAdviceMap[$field.val()];
        if (adviceText) {
          var adviceHTML = '<div class="subtype-format-advice add-label-margin"><strong>Use this subformat for…</strong> '+adviceText+'</div>';
          $container.append(adviceHTML);
        }
      }).change();
    },

    toggleNonEnglishSupport: function toggleNonEnglishSupport() {
      if ( !this.$form.hasClass('js-supports-non-english') ) return;
      // only toggle foreign language fields when news article type is editable
      if ( $( "select#edition_news_article_type_id" ).length == 0 ) return;

      var $form = this.$form;

      $().ready(function() {
        var $newsTypeSelect = $('select#edition_news_article_type_id')
        var $foreignLanguageFieldset = $(this).find('fieldset.foreign-language');
        var $foreignLanguageToggle = $('input#create_foreign_language_only')
        var $localeInput = $(this).find('#edition_primary_locale');
        var worldNewsStoryType = 4

        var toggleVisibility = function() {
          if ($newsTypeSelect.val() == worldNewsStoryType) {
            $foreignLanguageFieldset.show();
          } else {
            $foreignLanguageFieldset.hide();

            // reset foreign language options
            $foreignLanguageToggle.prop("checked", false)
            $localeInput.val('');
            $form.find('fieldset').removeClass('right-to-left');
          }
        }

        $newsTypeSelect.change(toggleVisibility)
        toggleVisibility();
      })
    },

    toggleLanguageSelect: function toggleLanguageSelect() {
      if ( !this.$form.hasClass('js-supports-non-english') ) return;

      var $form = this.$form;

      $().ready(function() {
        var $localeInput = $(this).find('#edition_primary_locale');

        var toggleVisibility = function() {
          if ($('input#create_foreign_language_only').prop('checked')) {
            $('.foreign-language-select').show();
          } else {
            $('.foreign-language-select').hide();

            // reset back to the default locale
            $localeInput.val('');
            $form.find('fieldset').removeClass('right-to-left');
          }
        }

        $('input#create_foreign_language_only').change(toggleVisibility)
        toggleVisibility();

        // setup observer to apply right-to-left classes to all form fieldsets
        $('#edition_primary_locale').change(function () {
          if ( $.inArray($(this).val(), GOVUK.adminEditionsForm.rightToLeftLocales) > -1) {
            $form.find('fieldset').addClass('right-to-left');
          } else {
            $form.find('fieldset').removeClass('right-to-left');
          }
        });
      })
    },

    toggleFirstPublishedDate: function toggleFirstPublishedDate() {
      // datetime_select can't set defaults if include_blank is true, so do it here.
      $('#edition_first_published_at_4i, #edition_first_published_at_5i').each(function(index) {
        var $this = $(this);
        if ($this.val() == '') {
          $this.val('00');
        }
      });
      var $firstPublished = $('.first-published-date .js-show-first-published');
      var $previouslyPublished_button = $('#edition_previously_published_true');
      var $radioButtons = $('.first-published-date input[type=radio]');

      function showOrHideDateSelector() {
        if ($previouslyPublished_button.prop('checked')){
          $firstPublished.show();
        } else {
          $firstPublished.hide();
        }
      }
      $radioButtons.on('change', showOrHideDateSelector);
      showOrHideDateSelector();

      $('.js-existing-first-published a').on('click', function(e) {
        $(this).parent().hide().next().removeClass('if-js-hide');
        e.preventDefault();
      });
    }
  }

  window.GOVUK.adminEditionsForm = adminEditionsForm;
}());
