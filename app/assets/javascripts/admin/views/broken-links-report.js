window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function BrokenLinksReport (module) {
    this.module = module
  }

  BrokenLinksReport.prototype.init = function () {
    if (!fetch) return
    var button = this.module.querySelector('button')
    var authenticityTokenField = this.module.querySelector('[name="authenticity_token"]')
    if (button && authenticityTokenField) this.setupEventListener(button, authenticityTokenField.value)
    var refreshLink = this.module.querySelector('.js-broken-links-refresh')
    if (refreshLink) {
      this.setupPolling(refreshLink)
    }
  }

  BrokenLinksReport.prototype.setupEventListener = function (button, authenticityToken) {
    var action = this.module.querySelector('.js-broken-links-form').action
    button.addEventListener('click', function (event) {
      event.preventDefault()
      fetch(action + '.json', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ authenticity_token: authenticityToken })
      }).then(function (response) { return response.json() })
        .catch(function () { location.reload() })
        .then(function (json) {
          this.replaceContents(json.html)
          this.init()
        }.bind(this))
    }.bind(this))
  }

  BrokenLinksReport.prototype.setupPolling = function (refreshLink) {
    refreshLink.parentElement.remove()

    var retries = 10
    var retry = function () {
      retries -= 1
      if (retries === 0) {
        this.module.addChild(refreshLink.parentElement)
        return
      }

      setTimeout(function () {
        this.poll(refreshLink.dataset.jsonHref, retry)
      }.bind(this), 2000)
    }.bind(this)

    retry()
  }

  BrokenLinksReport.prototype.poll = function (href, retry) {
    fetch(href).then(function (response) { return response.json() })
      .then(function (json) {
        if (json.inProgress) {
          retry()
        } else {
          this.replaceContents(json.html)
          this.init()
        }
      }.bind(this))
      .catch(function () { retry() })
  }

  BrokenLinksReport.prototype.replaceContents = function (html) {
    this.module.innerHTML = html
    this.module.firstChild.outerHTML = this.module.firstChild.innerHTML
  }

  Modules.BrokenLinksReport = BrokenLinksReport
})(window.GOVUK.Modules)
