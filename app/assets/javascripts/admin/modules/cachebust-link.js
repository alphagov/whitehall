'use strict'
/* Refreshes the `cachebust` query param on a link to the current unix-epoch
 * the moment the user is about to activate it, so the URL never carries a
 * stale timestamp from page load.
 *
 * Listens on `pointerdown` (mouse, touch, pen) and `focus` (keyboard, AT).
 * Usage: add `data-module="CachebustLink"` to the <a> tag.
 */
;(function (Modules) {
  function CachebustLink(link) {
    this.link = link
  }

  CachebustLink.prototype.init = function () {
    const refresh = this.refresh.bind(this)
    this.link.addEventListener('pointerdown', refresh)
    this.link.addEventListener('focus', refresh)
  }

  CachebustLink.prototype.refresh = function () {
    const url = new URL(this.link.href)
    if (!url.searchParams.has('cachebust')) return
    url.searchParams.set('cachebust', Math.floor(Date.now() / 1000))
    this.link.href = url.toString()
  }

  Modules.CachebustLink = CachebustLink
})(window.GOVUK.Modules)
