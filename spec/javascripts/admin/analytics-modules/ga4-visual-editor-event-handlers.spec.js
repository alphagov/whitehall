describe('GOVUK.analyticsGa4.analyticsModules.Ga4VisualEditorEventHandlers', function () {
  it('triggers ga4 tracking on visualEditorSelectChange event', function () {
    document.title = 'Title - Text'
    const select = document.createElement('select')
    document.body.appendChild(select)

    const mockGa4SendData = spyOn(
      window.GOVUK.analyticsGa4.core,
      'applySchemaAndSendData'
    )

    const ga4VisualEditorEventHandlers =
      new GOVUK.analyticsGa4.analyticsModules.Ga4VisualEditorEventHandlers(
        document
      )
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
      section: 'Title',
      action: 'DROPDOWN',
      tool_name: 'Visual Editor'
    }

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })

  it('triggers ga4 tracking on visualEditorButtonClick event', function () {
    document.title = 'Title - Text'
    const button = document.createElement('button')
    document.body.appendChild(button)

    const mockGa4SendData = spyOn(
      window.GOVUK.analyticsGa4.core,
      'applySchemaAndSendData'
    )

    const ga4VisualEditorEventHandlers =
      new GOVUK.analyticsGa4.analyticsModules.Ga4VisualEditorEventHandlers(
        document
      )
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
      section: 'Title',
      action: 'select',
      tool_name: 'Visual Editor'
    }

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })
})
