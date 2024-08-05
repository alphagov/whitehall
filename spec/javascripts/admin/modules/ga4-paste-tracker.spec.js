describe('GOVUK.analyticsGa4.analyticsModules.Ga4PasteTracker', function () {
  it('triggers ga4 tracking on paste event', function () {
    const mockGa4SendData = spyOn(
      window.GOVUK.analyticsGa4.core,
      'applySchemaAndSendData'
    )

    const ga4PasteTracker =
      new GOVUK.analyticsGa4.analyticsModules.Ga4PasteTracker(document)
    ga4PasteTracker.init()
    window.dispatchEvent(new ClipboardEvent('paste', {}))

    const expectedAttributes = {
      event_name: 'paste',
      type: 'paste',
      action: 'paste',
      method: 'browser paste'
    }

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })
})
