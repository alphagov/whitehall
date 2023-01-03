describe('GOVUK.Modules.GovspekEditor', function () {
  var component, module

  beforeEach(function () {
    component = document.createElement('div')
    component.setAttribute('data-image-ids', JSON.stringify([1, 2, 3, 4]))
    component.setAttribute('data-alternative-format-provider-id', 11)

    // Preview Button
    var previewButton = document.createElement('button')
    previewButton.classList.add('js-app-c-govspeak-editor__preview-button')
    previewButton.setAttribute('data-preview-toggle-tracking', true)
    previewButton.setAttribute('data-preview-toggle-track-category', 'govspeak-editor')
    previewButton.setAttribute('data-preview-toggle-track-action', 'pressed-preview-button')
    previewButton.setAttribute('data-content-target', '#textarea_id')
    previewButton.innerText = 'Preview'

    // Textarea
    var textareaSection = document.createElement('div')
    textareaSection.classList.add('app-c-govspeak-editor__textarea')

    var textarea = document.createElement('textarea')
    textarea.id = 'textarea_id'
    textarea.innerText = '## Hello'
    textareaSection.appendChild(textarea)

    // Preview section
    var previewSection = document.createElement('div')
    previewSection.classList.add('app-c-govspeak-editor__preview')

    // Append to component
    component.appendChild(previewButton)
    component.appendChild(textareaSection)
    component.appendChild(previewSection)

    module = new GOVUK.Modules.GovspeakEditor(component)
    module.init()

    spyOn(module, 'getCsrfToken').and.returnValue('a-csrf-token')

    jasmine.Ajax.install()
  })

  afterEach(function () {
    jasmine.Ajax.uninstall()
  })

  it('renders component correctly', function () {
    expect(component.querySelectorAll('.js-app-c-govspeak-editor__preview-button').length).toEqual(1)
    expect(component.querySelector('.js-app-c-govspeak-editor__preview-button').getAttribute('data-preview-toggle-tracking')).toEqual('true')

    expect(component.querySelectorAll('.app-c-govspeak-editor__textarea').length).toEqual(1)
    expect(component.querySelectorAll('.app-c-govspeak-editor__textarea textarea').length).toEqual(1)
    expect(component.querySelector('.app-c-govspeak-editor__textarea')).not.toHaveClass('app-c-govspeak-editor__textarea--hidden')

    expect(component.querySelectorAll('.app-c-govspeak-editor__preview').length).toEqual(1)
    expect(component.querySelector('.app-c-govspeak-editor__preview')).not.toHaveClass('app-c-govspeak-editor__preview--show')
  })

  it('shows preview section when button clicked', function () {
    var previewButton = component.querySelector('.js-app-c-govspeak-editor__preview-button')
    var textareaSection = component.querySelector('.app-c-govspeak-editor__textarea')
    var previewSection = component.querySelector('.app-c-govspeak-editor__preview')

    expect(textareaSection).not.toHaveClass('app-c-govspeak-editor__textarea--hidden')
    expect(previewSection).not.toHaveClass('app-c-govspeak-editor__preview--show')

    previewButton.dispatchEvent(new Event('click'))

    expect(textareaSection).toHaveClass('app-c-govspeak-editor__textarea--hidden')
    expect(previewSection).toHaveClass('app-c-govspeak-editor__preview--show')
    expect(previewButton.innerText).toEqual('Back to edit')
  })

  it('shows textarea section when you toggle back to edit', function () {
    var previewButton = component.querySelector('.js-app-c-govspeak-editor__preview-button')
    var textareaSection = component.querySelector('.app-c-govspeak-editor__textarea')
    var previewSection = component.querySelector('.app-c-govspeak-editor__preview')

    expect(textareaSection).not.toHaveClass('app-c-govspeak-editor__textarea--hidden')
    expect(previewSection).not.toHaveClass('app-c-govspeak-editor__preview--show')
    expect(previewButton.innerText).toEqual('Preview')

    previewButton.dispatchEvent(new Event('click'))

    expect(textareaSection).toHaveClass('app-c-govspeak-editor__textarea--hidden')
    expect(previewSection).toHaveClass('app-c-govspeak-editor__preview--show')
    expect(previewButton.innerText).toEqual('Back to edit')

    previewButton.dispatchEvent(new Event('click'))

    expect(textareaSection).not.toHaveClass('app-c-govspeak-editor__textarea--hidden')
    expect(previewSection).not.toHaveClass('app-c-govspeak-editor__preview--show')
    expect(previewButton.innerText).toEqual('Preview')
  })

  it('renders govspeak correctly on preview', function () {
    var previewButton = component.querySelector('.js-app-c-govspeak-editor__preview-button')
    var previewSection = component.querySelector('.app-c-govspeak-editor__preview')
    var html = [
      '<section class="document_page">',
      '<article class="document">',
      '<div class="body">',
      '<div class="govspeak">',
      '<h2>Hello</h2>',
      '</div>',
      '</div>',
      '</article>',
      '</section>'
    ].join('')

    jasmine.Ajax.stubRequest('/government/admin/preview', null, 'POST').andReturn({
      status: 200,
      contentType: 'text/html',
      responseText: html
    })

    previewButton.dispatchEvent(new Event('click'))

    expect(previewSection.innerHTML).toEqual(html)
  })

  it('renders govspeak correctly with changing content', function () {
    var previewButton = component.querySelector('.js-app-c-govspeak-editor__preview-button')
    var textarea = component.querySelector('#textarea_id')
    var previewSection = component.querySelector('.app-c-govspeak-editor__preview')
    var html = [
      '<section class="document_page">',
      '<article class="document">',
      '<div class="body">',
      '<div class="govspeak">',
      '<h2>Hello</h2>',
      '</div>',
      '</div>',
      '</article>',
      '</section>'
    ].join('')

    jasmine.Ajax.stubRequest('/government/admin/preview', null, 'POST').andReturn({
      status: 200,
      contentType: 'text/html',
      responseText: html
    })

    previewButton.dispatchEvent(new Event('click'))

    expect(previewSection.innerHTML).toEqual(html)

    // back to edit
    previewButton.dispatchEvent(new Event('click'))

    textarea.innerText = '## Hello this is a heading'
    var newHtml = [
      '<section class="document_page">',
      '<article class="document">',
      '<div class="body">',
      '<div class="govspeak">',
      '<h2>Hello this is a heading</h2>',
      '</div>',
      '</div>',
      '</article>',
      '</section>'
    ].join('')

    jasmine.Ajax.stubRequest('/government/admin/preview', null, 'POST').andReturn({
      status: 200,
      contentType: 'text/html',
      responseText: newHtml
    })

    previewButton.dispatchEvent(new Event('click'))

    expect(previewSection.innerHTML).toEqual(newHtml)
  })

  it('sends tracking events correctly', function () {
    spyOn(GOVUK.analytics, 'trackEvent')
    var previewButton = component.querySelector('.js-app-c-govspeak-editor__preview-button')

    previewButton.dispatchEvent(new Event('click'))

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'govspeak-editor',
      'pressed-preview-button',
      { label: 'preview' }
    )

    previewButton.dispatchEvent(new Event('click'))

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'govspeak-editor',
      'pressed-preview-button',
      { label: 'edit' }
    )
  })

  it('generates form data correctly', function () {
    var formData = module.generateFormData('some text')

    expect(Array.from(formData.entries())).toEqual([
      ['body', 'some text'],
      ['authenticity_token', 'a-csrf-token'],
      ['alternative_format_provider_id', '11'],
      ['image_ids[]', '1'],
      ['image_ids[]', '2'],
      ['image_ids[]', '3'],
      ['image_ids[]', '4']
    ])
  })
})
