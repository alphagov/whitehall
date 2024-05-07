//= require govspeak-visual-editor/dist/govspeak-visual-editor.js

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function VisualEditor(module) {
    this.module = module
  }

  VisualEditor.prototype.init = function () {
    this.content = this.module.querySelector('.app-c-visual-editor__content')
    this.container = this.module.querySelector(
      '.app-c-visual-editor__container'
    )
    this.textarea = this.module.querySelector(
      '.app-c-visual-editor__govspeak-editor-wrapper textarea'
    )

    new window.GovspeakVisualEditor(this.content, this.container, this.textarea) // eslint-disable-line no-new

    this.govspeakEditorwrapper = this.module.querySelector(
      '.app-c-visual-editor__govspeak-editor-wrapper'
    )
    this.visualEditorWrapper = this.module.querySelector(
      '.app-c-visual-editor__visual-editor-wrapper'
    )
    this.exitButton = this.module.querySelector(
      '.js-app-c-visual-editor__exit-button'
    )
    this.visual_editor_flag = document.querySelector(
      '.app-c-visual-editor__hidden-field'
    )
    this.contentEditable = this.container.querySelector(
      'div[contenteditable="true"]'
    )

    this.exitButton.addEventListener('click', this.hideVisualEditor.bind(this))
    this.showVisualEditor()
  }

  VisualEditor.prototype.showVisualEditor = function () {
    this.govspeakEditorwrapper.classList.add(
      'app-c-visual-editor__govspeak-editor-wrapper--hidden'
    )
    this.visualEditorWrapper.classList.add(
      'app-c-visual-editor__visual-editor-wrapper--show'
    )
    this.visual_editor_flag.value = true

    this.contentEditable.setAttribute('id', this.textarea.getAttribute('id'))
    this.textarea.removeAttribute('id')
  }

  VisualEditor.prototype.hideVisualEditor = function () {
    this.govspeakEditorwrapper.classList.remove(
      'app-c-visual-editor__govspeak-editor-wrapper--hidden'
    )
    this.visualEditorWrapper.classList.remove(
      'app-c-visual-editor__visual-editor-wrapper--show'
    )
    this.visual_editor_flag.value = false

    this.textarea.setAttribute('id', this.contentEditable.getAttribute('id'))
    this.contentEditable.removeAttribute('id')
  }

  Modules.VisualEditor = VisualEditor
})(window.GOVUK.Modules)
