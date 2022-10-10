//= require paste-html-to-govspeak/dist/paste-html-to-markdown.js

(function (Modules) {
  'use strict'

  Modules.PasteHtmlToGovspeak = function () {
    this.start = function (element) {
      element[0].addEventListener('paste', window.pasteHtmlToGovspeak.pasteListener)
    }
  }
})(window.GOVUKAdmin.Modules)
