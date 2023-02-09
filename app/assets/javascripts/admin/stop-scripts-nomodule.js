// In browsers that do not support ES6 modules
if (!('noModule' in HTMLScriptElement.prototype)) {
  // Remove any JavaScript reliant style changes.
  document.body.classList.remove('js-enabled')

  // Prevent the GOV.UK Frontend from being initialised.
  document.addEventListener('DOMContentLoaded', function (e) {
    e.stopImmediatePropagation()
    e.stopPropagation()
  }, true)
}
