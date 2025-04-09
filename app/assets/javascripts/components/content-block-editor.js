//= require content-block-editor/dist/content-block-editor.js
'use strict'

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}

;(function (Modules) {
  function ContentBlockEditor (module) {
    this.module = module.querySelector('textarea')
  }

  ContentBlockEditor.prototype.init = function () {
    new window.ContentBlockEditor(this.module) // eslint-disable-line no-new

    const insertButton = document.querySelector('.content-block-editor__toggle-button')
    const previewButton = document.querySelector('.js-app-c-govspeak-editor__preview-button')
    const backButton = document.querySelector('.js-app-c-govspeak-editor__back-button')

    previewButton.before(insertButton)

    previewButton.addEventListener('click', () => {
      insertButton.classList.add('govuk-visually-hidden')
    })

    backButton.addEventListener('click', () => {
      insertButton.classList.remove('govuk-visually-hidden')
    })
  }

  Modules.ContentBlockEditor = ContentBlockEditor
})(window.GOVUK.Modules)
