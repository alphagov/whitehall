window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function EditionForm (module) {
    this.module = module
  }

  EditionForm.prototype.init = function () {
    this.setupFormatAdviceForSelectedSubtypeEventListener()
  }

  EditionForm.prototype.setupFormatAdviceForSelectedSubtypeEventListener = function () {
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

  Modules.EditionForm = EditionForm
})(window.GOVUK.Modules)
