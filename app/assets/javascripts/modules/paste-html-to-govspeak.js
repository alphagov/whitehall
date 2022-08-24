//= require paste-html-to-govspeak/dist/paste-html-to-markdown.js

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function PasteHtmlToGovspeak ($module) {
    this.$module = $module
  }

  PasteHtmlToGovspeak.prototype.init = function () {
    this.$module.addEventListener('paste', window.pasteHtmlToGovspeak.pasteListener)
  }


  Modules.PasteHtmlToGovspeak = PasteHtmlToGovspeak
})(window.GOVUK.Modules)
