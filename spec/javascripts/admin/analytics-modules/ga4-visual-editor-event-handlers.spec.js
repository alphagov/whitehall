describe('GOVUK.analyticsGa4.analyticsModules.Ga4VisualEditorEventHandlers', function () {
  it('triggers ga4 tracking on visualEditorSelectChange event', function () {
    const container = document.createElement('div')
    const select = document.createElement('select')
    container.setAttribute('data-module', 'ga4-visual-editor-event-handlers')
    container.appendChild(select)
    document.body.appendChild(container)

    const mockGa4SendData = spyOn(
      window.GOVUK.analyticsGa4.core,
      'applySchemaAndSendData'
    )

    const ga4VisualEditorEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4VisualEditorEventHandlers
    ga4VisualEditorEventHandlers.init()
    select.dispatchEvent(
      new CustomEvent('visualEditorSelectChange', {
        bubbles: true,
        detail: {
          selectText: 'DROPDOWN'
        }
      })
    )

    const expectedAttributes = {
      event_name: 'select_content',
      type: 'select',
      text: 'DROPDOWN',
      tool_name: 'Visual Editor'
    }

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })

  it('triggers ga4 tracking on visualEditorButtonClick event', function () {
    const container = document.createElement('div')
    const button = document.createElement('button')
    container.setAttribute('data-module', 'ga4-visual-editor-event-handlers')
    container.appendChild(button)
    document.body.appendChild(container)

    const mockGa4SendData = spyOn(
      window.GOVUK.analyticsGa4.core,
      'applySchemaAndSendData'
    )

    const ga4VisualEditorEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4VisualEditorEventHandlers
    ga4VisualEditorEventHandlers.init()
    button.dispatchEvent(
      new CustomEvent('visualEditorButtonClick', {
        bubbles: true,
        detail: {
          buttonText: 'BUTTON'
        }
      })
    )

    const expectedAttributes = {
      event_name: 'select_content',
      type: 'generic_link',
      text: 'BUTTON',
      external: 'false',
      method: 'primary click',
      tool_name: 'Visual Editor'
    }

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })
})
