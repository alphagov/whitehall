//= require content-block-editor/dist/content-block-editor.js
'use strict'

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}

;(function (Modules) {
  function ContentBlockEditorWrapper (module) {
    this.module = module.querySelector('textarea')
  }

  ContentBlockEditorWrapper.prototype.init = function () {
    const contentBlockEditor = new window.ContentBlockEditor(this.module)
    contentBlockEditor.initialize()
  }

  Modules.ContentBlockEditorWrapper = ContentBlockEditorWrapper
})(window.GOVUK.Modules)
