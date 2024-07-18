window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  const gaSelectChangeAttributes = function (selectText) {
    return {
      event_name: 'select_content',
      type: 'select',
      text: selectText,
      section: document.title.split(' - ')[0].replace('Error: ', ''),
      action: selectText,
      tool_name: 'Visual Editor'
    }
  }

  function Ga4VisualEditorEventHandlers(module) {
    this.module = module
  }

  Ga4VisualEditorEventHandlers.prototype.init = function () {
    this.module.addEventListener('visualEditorSelectChange', (event) => {
      window.GOVUK.analyticsGa4.core.applySchemaAndSendData(
        gaSelectChangeAttributes(event.detail.selectText),
        'event_data'
      )
    })
  }

  Modules.Ga4VisualEditorEventHandlers = Ga4VisualEditorEventHandlers
})(window.GOVUK.Modules)
