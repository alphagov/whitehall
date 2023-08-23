describe('GOVUK.Modules.PasteHtmlToGovspeak', function () {
  let textarea

  function createHtmlPasteEvent (html = null) {
    const event = new window.Event('paste')
    event.clipboardData = {
      getData: (type) => {
        if (type === 'text/html') {
          return html
        }
      }
    }

    return event
  }

  beforeEach(function () {
    textarea = document.createElement('textarea')

    const pasteHtmlToGovspeak = new GOVUK.Modules.PasteHtmlToGovspeak(textarea)
    pasteHtmlToGovspeak.init()
  })

  it('responds to a paste event by converting the HTML to Govspeak', function () {
    textarea.dispatchEvent(createHtmlPasteEvent('<h2>This is a h2</h2>'))

    expect(textarea.value).toEqual('## This is a h2')
  })
})
