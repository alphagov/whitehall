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

    new window.GovspeakVisualEditor(this.content, this.container, this.textarea) // eslint-disable-line no-new
  }

  Modules.VisualEditor = VisualEditor
})(window.GOVUK.Modules)
