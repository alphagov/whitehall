window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function EditionForm (module) {
    this.module = module
  }

  EditionForm.prototype.init = function () {
    this.setupSubtypeFormatAdviceEventListener()
    this.setupWorldNewsStoryVisibilityToggle()
  }

  EditionForm.prototype.setupSubtypeFormatAdviceEventListener = function () {
    var form = this.module
    var subtypeDiv = form.querySelector('.edition-form__subtype-fields')

    if (!subtypeDiv) { return }

    var subtypeSelect = subtypeDiv.querySelector('select')

    subtypeSelect.addEventListener('change', function () {
      var formatAdviceMap = JSON.parse(subtypeDiv.dataset.formatAdvice)
      var subtypeFormatAdvice = form.querySelector('.edition-form__subtype-format-advice')

      if (subtypeFormatAdvice) {
        subtypeDiv.removeChild(subtypeFormatAdvice)
      }

      var adviceText = formatAdviceMap[subtypeSelect.value]

      if (adviceText) {
        var div = document.createElement('div')
        div.classList.add('edition-form__subtype-format-advice', 'govuk-body', 'govuk-!-margin-top-4')
        div.innerHTML = '<strong>Use this subformat for…</strong> ' + adviceText
        subtypeDiv.append(div)
      }
    })
  }

  EditionForm.prototype.setupWorldNewsStoryVisibilityToggle = function () {
    var form = this.module

    var select = form.querySelector('#edition_news_article_type_id')

    if (!select) { return }

    var container = form.querySelector('.app-view-edit-edition__locale-field')
    var localeCheckbox = container.querySelector('#edition_create_foreign_language_only-0')
    var localeSelect = container.querySelector('#edition_primary_locale')
    var newArticleTypeId = '4'

    select.addEventListener('change', function () {
      if (select.value !== newArticleTypeId) {
        container.classList.add('app-view-edit-edition__locale-field--hidden')
        localeCheckbox.value = '0'
        localeCheckbox.checked = false
        localeSelect.value = ''
      } else {
        container.classList.remove('app-view-edit-edition__locale-field--hidden')
      }
    })
  }

  Modules.EditionForm = EditionForm
})(window.GOVUK.Modules)
