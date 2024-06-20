describe('GOVUK.Modules.Ga4VisualEditorEventHandlers', function () {
  it('triggers ga4 tracking on visualEditorSelectChange event', function () {
    document.title = 'Title - Text'
    const select = document.createElement('select')
    document.body.appendChild(select)

    const mockGa4SendData = spyOn(
      window.GOVUK.analyticsGa4.core,
      'applySchemaAndSendData'
    )

    const ga4VisualEditorEventHandlers =
      new GOVUK.Modules.Ga4VisualEditorEventHandlers(document)
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
})
