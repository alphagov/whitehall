'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  const gaSelectChangeAttributes = function (selectText) {
    return {
      event_name: 'select_content',
      type: 'select',
      text: selectText,
      action: selectText,
      tool_name: 'Visual Editor'
    }
  }

  const gaButtonClickAttributes = function (buttonText) {
    return {
      event_name: 'select_content',
      type: 'generic_link',
      text: buttonText,
      external: 'false',
      method: 'primary click',
      action: 'select',
      tool_name: 'Visual Editor'
    }
  }

  Modules.Ga4VisualEditorEventHandlers = {
    init: function () {
      const moduleElements = document.querySelectorAll(
        '[data-module~="ga4-visual-editor-event-handlers"]'
      )
      moduleElements.forEach(function (moduleElement) {
        moduleElement.addEventListener('visualEditorSelectChange', (event) => {
          window.GOVUK.analyticsGa4.core.applySchemaAndSendData(
            gaSelectChangeAttributes(event.detail.selectText),
            'event_data'
          )
        })

        moduleElement.addEventListener('visualEditorButtonClick', (event) => {
          window.GOVUK.analyticsGa4.core.applySchemaAndSendData(
            gaButtonClickAttributes(event.detail.buttonText),
            'event_data'
          )
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
