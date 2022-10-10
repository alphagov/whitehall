(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  var adminEditionsForm = {
    init: function init (params) {
      this.$form = $(params.selector)
      this.rightToLeftLocales = params.right_to_left_locales
      this.$newsTypeSelect = $('select#edition_news_article_type_id')

      this.showChangeNotesIfMajorChange()
      this.showFormatAdviceForSelectedSubtype()
      this.toggleLanguageSelect()
      this.toggleWorldNewsStoryVisibility()
      this.resetWorldNewsStoryFields()
      this.toggleFirstPublishedDate()
      this.showImageUploaderIfCustomImage()

      GOVUK.formChangeProtection.init($('#edit_edition'), 'You have unsaved changes that will be lost if you leave this page.')
    },

    showChangeNotesIfMajorChange: function showChangeNotesIfMajorChange () {
      var $fieldset = $('.js-change-notes', this.$form)
      var $radioButtons = $('input[type=radio]', $fieldset)
      var $minorChangeRadioButton = $('#edition_minor_change_true', $fieldset)
      var $changeNotesSection = $('.js-change-notes-section', $fieldset)

      $radioButtons.change(showOrHideChangeNotes)
      showOrHideChangeNotes()

      function showOrHideChangeNotes () {
        if ($minorChangeRadioButton.prop('checked')) {
          $changeNotesSection.slideUp(200)
        } else {
          $changeNotesSection.slideDown(200)
        }
      }
    },

    showFormatAdviceForSelectedSubtype: function showFormatAdviceForSelectedSubtype () {
      var $subtypeFields = $('.subtype', this.$form).filter('select')

      if ($subtypeFields.length < 1) { return }

      $subtypeFields.change(function () {
        var $field = $(this)
        var $container = $field.parent()
        var formatAdviceMap = $field.data('format-advice')

        $container.find('.subtype-format-advice').remove()

        var adviceText = formatAdviceMap[$field.val()]
        if (adviceText) {
          var adviceHTML = '<div class="subtype-format-advice add-label-margin"><strong>Use this subformat for…</strong> ' + adviceText + '</div>'
          $container.append(adviceHTML)
        }
      }).change()
    },

    toggleLanguageSelect: function toggleLanguageSelect () {
      if (!this.$form.hasClass('js-supports-non-english')) return

      var $form = this.$form

      $().ready(function () {
        var $localeInput = $(this).find('#edition_primary_locale')

        var toggleVisibility = function () {
          if ($('input#create_foreign_language_only').prop('checked')) {
            $('.foreign-language-select').show()
          } else {
            $('.foreign-language-select').hide()

            // reset back to the default locale
            $localeInput.val('')
            $form.find('fieldset').removeClass('right-to-left')
          }
        }

        $('input#create_foreign_language_only').change(toggleVisibility)
        toggleVisibility()

        // setup observer to apply right-to-left classes to all form fieldsets
        $('#edition_primary_locale').change(function () {
          if ($.inArray($(this).val(), GOVUK.adminEditionsForm.rightToLeftLocales) > -1) {
            $form.find('fieldset').addClass('right-to-left')
          } else {
            $form.find('fieldset').removeClass('right-to-left')
          }
        })
      })
    },

    toggleWorldNewsStoryVisibility: function toggleWorldNewsStoryVisibility () {
      // only toggle fields when news article type is editable
      if ($('select#edition_news_article_type_id').length === 0) return

      var $nonWorldNewsStoryFieldsets = this.findFieldsets(this.nonWorldNewsStoryFieldSelectors())
      var $worldNewsStoryFieldsets = this.findFieldsets(this.worldNewsStoryFieldSelectors())

      var _this = this
      $().ready(function () {
        var toggleFields = function () {
          if (_this.isWorldNewsStorySelected()) {
            _this.hideFieldsets($nonWorldNewsStoryFieldsets)
            _this.showFieldsets($worldNewsStoryFieldsets)
          } else {
            _this.hideFieldsets($worldNewsStoryFieldsets)
            _this.showFieldsets($nonWorldNewsStoryFieldsets)
          }
        }

        _this.$newsTypeSelect.change(toggleFields)
        toggleFields()
      })
    },

    findFieldsets: function (fieldSelectors) {
      return $.map(fieldSelectors, function (fieldSelector) {
        return $('fieldset.' + fieldSelector)
      })
    },

    nonWorldNewsStoryFieldSelectors: function () {
      return [
        'policies',
        'role-appointments',
        'organisations'
      ]
    },

    worldNewsStoryFieldSelectors: function () {
      return [
        'foreign-language',
        'worldwide-organisations'
      ]
    },

    isWorldNewsStorySelected: function () {
      var worldNewsStoryTypeValue = '4'

      return this.$newsTypeSelect.val() === worldNewsStoryTypeValue
    },

    hideFieldsets: function (fieldsets) {
      $.each(fieldsets, function (index, fieldset) {
        fieldset.hide()
      })
    },

    showFieldsets: function (fieldsets) {
      $.each(fieldsets, function (index, fieldset) {
        fieldset.show()
      })
    },

    resetWorldNewsStoryFields: function resetWorldNewsStoryFields () {
      // only toggle fields when news article type is editable
      if ($('select#edition_news_article_type_id').length === 0) return

      var $nonWorldNewsStoryMultipleSelectInputs = this.findSelectInputs(this.nonWorldNewsStoryMultipleSelectInputSelectors())
      var $nonWorldNewsStorySelectInputs = this.findSelectInputs(this.nonWorldNewsStorySelectInputSelectors())
      var $worldNewsStoryMultipleSelectInputs = this.findSelectInputs(this.worldNewsStorySelectInputSelectors())

      var _this = this
      var resetFields = function () {
        if (_this.isWorldNewsStorySelected()) {
          _this.resetMultipleSelectInputs($nonWorldNewsStoryMultipleSelectInputs)
          _this.resetSelectInputs($nonWorldNewsStorySelectInputs)
        } else {
          _this.resetForeignLanguageFields()
          _this.resetMultipleSelectInputs($worldNewsStoryMultipleSelectInputs)
        }
      }

      this.$newsTypeSelect.change(resetFields)
      resetFields()
    },

    findSelectInputs: function (fieldSelectors) {
      var $fieldSets = this.findFieldsets(fieldSelectors)

      return $.map($fieldSets, function (fieldSet) {
        return fieldSet.find('select')
      })
    },

    nonWorldNewsStoryMultipleSelectInputSelectors: function () {
      return [
        'policies',
        'role-appointments'
      ]
    },

    nonWorldNewsStorySelectInputSelectors: function () {
      return [
        'organisations'
      ]
    },

    worldNewsStorySelectInputSelectors: function () {
      return [
        'worldwide-organisations'
      ]
    },

    resetMultipleSelectInputs: function (selectInputs) {
      $.each(selectInputs, function (index, selectInput) {
        if (selectInput.val()) {
          selectInput.val([]).trigger('chosen:updated')
        }
      })
    },

    resetSelectInputs: function (selectInputs) {
      $.each(selectInputs, function (index, selectInput) {
        if (selectInput.val() !== '') {
          selectInput.val('').trigger('chosen:updated')
        }
      })
    },

    resetForeignLanguageFields: function () {
      var $form = this.$form
      var $foreignLanguageFieldset = $form.find('fieldset.foreign-language')
      var $foreignLanguageToggle = $form.find('input#create_foreign_language_only')
      var $localeInput = $foreignLanguageFieldset.find('#edition_primary_locale')
      var $allFormFieldsets = $form.find('fieldset')

      $foreignLanguageToggle.prop('checked', false)
      $localeInput.val('')
      $allFormFieldsets.removeClass('right-to-left')
    },

    toggleFirstPublishedDate: function toggleFirstPublishedDate () {
      // datetime_select can't set defaults if include_blank is true, so do it here.
      $('#edition_first_published_at_4i, #edition_first_published_at_5i').each(function (index) {
        var $this = $(this)
        if ($this.val() === '') {
          $this.val('00')
        }
      })
      var $firstPublished = $('.first-published-date .js-show-first-published')
      var $previouslyPublishedButton = $('#edition_previously_published_true')
      var $radioButtons = $('.first-published-date input[type=radio]')

      function showOrHideDateSelector () {
        if ($previouslyPublishedButton.prop('checked')) {
          $firstPublished.show()
        } else {
          $firstPublished.hide()
        }
      }
      $radioButtons.on('change', showOrHideDateSelector)
      showOrHideDateSelector()

      $('.js-existing-first-published a').on('click', function (e) {
        $(this).parent().hide().next().removeClass('if-js-hide')
        e.preventDefault()
      })
    },

    showImageUploaderIfCustomImage: function showImageUploaderIfCustomImage () {
      var $imageUploader = $('.image_section .js-show-image-uploader')
      var $customImageRadioButton = $('#edition_image_display_option_custom_image')
      var $radioButtons = $('.image_section input[type=radio]')

      function showOrHideImageUploader () {
        if ($customImageRadioButton.prop('checked')) {
          $imageUploader.show()
        } else {
          $imageUploader.hide()
        }
      }
      $radioButtons.on('change', showOrHideImageUploader)
      showOrHideImageUploader()
    }
  }

  window.GOVUK.adminEditionsForm = adminEditionsForm
}())
