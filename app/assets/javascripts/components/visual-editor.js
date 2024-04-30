//= require govspeak-visual-editor/dist/govspeak-visual-editor.js

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function VisualEditor(module) {
    this.module = module

    this.content = module.querySelector('.app-c-visual-editor__content')
    this.container = module.querySelector('.app-c-visual-editor__container')
    this.textarea = module.querySelector(
      '.app-c-visual-editor__textarea-wrapper textarea'
    )
  }

  VisualEditor.prototype.init = function () {
    this.textarea.classList.add('app-c-visual-editor__textarea--hidden')
    const id = this.textarea.getAttribute('id')
    this.textarea.removeAttribute('id')

    new window.GovspeakVisualEditor(this.content, this.container, this.textarea) // eslint-disable-line no-new

    this.container
      .querySelector('div[contenteditable="true"]')
      .setAttribute('id', id)
  }

  Modules.VisualEditor = VisualEditor
})(window.GOVUK.Modules)
