//= require paste-html-to-govspeak/dist/paste-html-to-markdown.js
'use strict'
;(function (Modules) {
  function PasteHtmlToGovspeak($module) {
    this.$module = $module
  }

  PasteHtmlToGovspeak.prototype.init = function () {
    this.$module.addEventListener(
      'paste',
      window.pasteHtmlToGovspeak.pasteListener
    )
  }

  Modules.PasteHtmlToGovspeak = PasteHtmlToGovspeak
})(window.GOVUK.Modules)
