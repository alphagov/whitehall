'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function AutoPopulateTelephoneNumberLabel(module) {
    this.module = module
  }

  AutoPopulateTelephoneNumberLabel.prototype.init = function () {
    const typeSelects = this.module.querySelectorAll(
      "select[name='content_block/edition[details][telephones][telephone_numbers][][type]']"
    )

    typeSelects.forEach(function (el) {
      el.addEventListener('change', this.setLabelValue.bind(this))
    }, this)

    // Wait for the Add another button to be present
    this.waitForElement('.js-add-another__add-button').then((element) => {
      // When the add another button is clicked, reinitialize the module
      element.addEventListener('click', this.init.bind(this))
    })
  }

  AutoPopulateTelephoneNumberLabel.prototype.setLabelValue = function (e) {
    const select = e.target
    const options = select.options
    const selectedIndex = select.selectedIndex
    const label = select
      .closest('fieldset')
      .querySelector(
        "input[name='content_block/edition[details][telephones][telephone_numbers][][label]']"
      )

    if (selectedIndex > 0) {
      label.value = options[selectedIndex].text
    }
  }

  AutoPopulateTelephoneNumberLabel.prototype.waitForElement = function (
    selector
  ) {
    return new Promise((resolve) => {
      const observer = new MutationObserver((mutations, observer) => {
        const element = document.querySelector(selector)
        if (element) {
          observer.disconnect()
          resolve(element)
        }
      })

      observer.observe(this.module, {
        childList: true,
        subtree: true
      })
    })
  }

  Modules.AutoPopulateTelephoneNumberLabel = AutoPopulateTelephoneNumberLabel
})(window.GOVUK.Modules)
