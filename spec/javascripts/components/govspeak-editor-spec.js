describe('GOVUK.Modules.GovspeakEditor', function () {
  let component, module

  beforeEach(function () {
    component = document.createElement('div')
    component.setAttribute('data-image-ids', JSON.stringify([1, 2, 3, 4]))
    component.setAttribute('data-attachment-ids', JSON.stringify([5, 6, 7, 8]))
    component.setAttribute('data-alternative-format-provider-id', 11)

    // Preview Button
    const previewButton = document.createElement('button')
    previewButton.classList.add('js-app-c-govspeak-editor__preview-button')
    previewButton.setAttribute('data-preview-toggle-tracking', true)
    previewButton.setAttribute(
      'data-preview-toggle-track-category',
      'govspeak-editor'
    )
    previewButton.setAttribute(
      'data-preview-toggle-track-action',
      'pressed-preview-button'
    )
    previewButton.setAttribute('data-content-target', '#textarea_id')
    previewButton.innerText = 'Preview'

    const backButton = document.createElement('button')
    backButton.classList.add('js-app-c-govspeak-editor__back-button')
    backButton.setAttribute('data-preview-toggle-tracking', true)
    backButton.setAttribute(
      'data-preview-toggle-track-category',
      'govspeak-editor'
    )
    backButton.setAttribute(
      'data-preview-toggle-track-action',
      'pressed-preview-button'
    )
    backButton.setAttribute('data-content-target', '#textarea_id')
    backButton.innerText = 'Back to edit'

    // Textarea
    const textareaSection = document.createElement('div')
    textareaSection.classList.add('app-c-govspeak-editor__textarea')

    const textarea = document.createElement('textarea')
    textarea.id = 'textarea_id'
    textarea.innerText = '## Hello'
    textareaSection.appendChild(textarea)

    // Preview section
    const previewSection = document.createElement('div')
    previewSection.classList.add('app-c-govspeak-editor__preview')

    // Error section
    const errorSection = document.createElement('div')
    errorSection.classList.add('app-c-govspeak-editor__error')

    // Append to component
    component.appendChild(previewButton)
    component.appendChild(backButton)
    component.appendChild(textareaSection)
    component.appendChild(previewSection)
    component.appendChild(errorSection)
  })

  describe('without visual editor', function () {
    beforeEach(function () {
      module = new GOVUK.Modules.GovspeakEditor(component)
      module.init()

      spyOn(module, 'getCsrfToken').and.returnValue('a-csrf-token')

      jasmine.Ajax.install()
    })

    afterEach(function () {
      jasmine.Ajax.uninstall()
    })

    it('renders component correctly', function () {
      expect(
        component.querySelectorAll('.js-app-c-govspeak-editor__preview-button')
          .length
      ).toEqual(1)
      expect(
        component
          .querySelector('.js-app-c-govspeak-editor__preview-button')
          .getAttribute('data-preview-toggle-tracking')
      ).toEqual('true')

      expect(
        component.querySelectorAll('.app-c-govspeak-editor__textarea').length
      ).toEqual(1)
      expect(
        component.querySelectorAll('.app-c-govspeak-editor__textarea textarea')
          .length
      ).toEqual(1)
      expect(
        component.querySelector('.app-c-govspeak-editor__textarea')
      ).not.toHaveClass('app-c-govspeak-editor__textarea--hidden')

      expect(
        component.querySelectorAll('.app-c-govspeak-editor__preview').length
      ).toEqual(1)
      expect(
        component.querySelector('.app-c-govspeak-editor__preview')
      ).not.toHaveClass('app-c-govspeak-editor__preview--show')

      expect(
        component.querySelectorAll('.app-c-govspeak-editor__error').length
      ).toEqual(1)
      expect(
        component.querySelector('.app-c-govspeak-editor__error')
      ).not.toHaveClass('app-c-govspeak-editor__error--show')
    })

    it('shows preview section when button clicked', function () {
      const previewButton = component.querySelector(
        '.js-app-c-govspeak-editor__preview-button'
      )
      const backButton = component.querySelector(
        '.js-app-c-govspeak-editor__back-button'
      )
      const textareaSection = component.querySelector(
        '.app-c-govspeak-editor__textarea'
      )
      const previewSection = component.querySelector(
        '.app-c-govspeak-editor__preview'
      )

      expect(textareaSection).not.toHaveClass(
        'app-c-govspeak-editor__textarea--hidden'
      )
      expect(previewSection).not.toHaveClass(
        'app-c-govspeak-editor__preview--show'
      )

      previewButton.dispatchEvent(new Event('click'))

      expect(textareaSection).toHaveClass(
        'app-c-govspeak-editor__textarea--hidden'
      )
      expect(previewSection).toHaveClass('app-c-govspeak-editor__preview--show')
      expect(previewButton).not.toHaveClass(
        'app-c-govspeak-editor__preview-button--show'
      )
      expect(backButton).toHaveClass('app-c-govspeak-editor__back-button--show')
    })

    it('shows textarea section when you toggle back to edit', function () {
      const previewButton = component.querySelector(
        '.js-app-c-govspeak-editor__preview-button'
      )
      const backButton = component.querySelector(
        '.js-app-c-govspeak-editor__back-button'
      )
      const textareaSection = component.querySelector(
        '.app-c-govspeak-editor__textarea'
      )
      const previewSection = component.querySelector(
        '.app-c-govspeak-editor__preview'
      )

      expect(textareaSection).not.toHaveClass(
        'app-c-govspeak-editor__textarea--hidden'
      )
      expect(previewSection).not.toHaveClass(
        'app-c-govspeak-editor__preview--show'
      )
      expect(previewButton.innerText).toEqual('Preview')

      previewButton.dispatchEvent(new Event('click'))

      expect(textareaSection).toHaveClass(
        'app-c-govspeak-editor__textarea--hidden'
      )
      expect(previewSection).toHaveClass('app-c-govspeak-editor__preview--show')
      expect(previewButton).not.toHaveClass(
        'app-c-govspeak-editor__preview-button--show'
      )
      expect(backButton).toHaveClass('app-c-govspeak-editor__back-button--show')

      backButton.dispatchEvent(new Event('click'))

      expect(textareaSection).not.toHaveClass(
        'app-c-govspeak-editor__textarea--hidden'
      )
      expect(previewSection).not.toHaveClass(
        'app-c-govspeak-editor__preview--show'
      )
      expect(previewButton.innerText).toEqual('Preview')
    })

    it('renders govspeak correctly on preview', function () {
      const previewButton = component.querySelector(
        '.js-app-c-govspeak-editor__preview-button'
      )
      const previewSection = component.querySelector(
        '.app-c-govspeak-editor__preview'
      )
      const html = [
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

      jasmine.Ajax.stubRequest(
        '/government/admin/preview',
        null,
        'POST'
      ).andReturn({
        status: 200,
        contentType: 'text/html',
        responseText: html
      })

      previewButton.dispatchEvent(new Event('click'))

      expect(previewSection.innerHTML).toEqual(html)
    })

    it('renders an error message when the govspeak service returns a 403 "forbidden" response', function () {
      const previewButton = component.querySelector(
        '.js-app-c-govspeak-editor__preview-button'
      )
      const previewSection = component.querySelector(
        '.app-c-govspeak-editor__preview'
      )
      const errorSection = component.querySelector(
        '.app-c-govspeak-editor__error'
      )

      jasmine.Ajax.stubRequest(
        '/government/admin/preview',
        null,
        'POST'
      ).andReturn({
        status: 403,
        contentType: 'text/html'
      })

      previewButton.dispatchEvent(new Event('click'))

      expect(errorSection.classList).toContain(
        'app-c-govspeak-editor__error--show'
      )
      expect(previewSection.classList).not.toContain(
        'app-c-govspeak-editor__preview--show'
      )
    })

    it('hides the error message when the user returns to the editor view', function () {
      const backButton = component.querySelector(
        '.js-app-c-govspeak-editor__back-button'
      )
      const errorSection = component.querySelector(
        '.app-c-govspeak-editor__error'
      )

      errorSection.classList.add('app-c-govspeak-editor__error--show')

      backButton.dispatchEvent(new Event('click'))

      expect(errorSection.classList).not.toContain(
        'app-c-govspeak-editor__error--show'
      )
    })

    it('renders govspeak correctly with changing content', function () {
      const previewButton = component.querySelector(
        '.js-app-c-govspeak-editor__preview-button'
      )
      const textarea = component.querySelector('#textarea_id')
      const previewSection = component.querySelector(
        '.app-c-govspeak-editor__preview'
      )
      const html = [
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

      jasmine.Ajax.stubRequest(
        '/government/admin/preview',
        null,
        'POST'
      ).andReturn({
        status: 200,
        contentType: 'text/html',
        responseText: html
      })

      previewButton.dispatchEvent(new Event('click'))

      expect(previewSection.innerHTML).toEqual(html)

      // back to edit
      previewButton.dispatchEvent(new Event('click'))

      textarea.innerText = '## Hello this is a heading'
      const newHtml = [
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

      jasmine.Ajax.stubRequest(
        '/government/admin/preview',
        null,
        'POST'
      ).andReturn({
        status: 200,
        contentType: 'text/html',
        responseText: newHtml
      })

      previewButton.dispatchEvent(new Event('click'))

      expect(previewSection.innerHTML).toEqual(newHtml)
    })

    it('sends tracking events correctly', function () {
      spyOn(GOVUK.analytics, 'trackEvent')
      const previewButton = component.querySelector(
        '.js-app-c-govspeak-editor__preview-button'
      )

      previewButton.dispatchEvent(new Event('click'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'govspeak-editor',
        'pressed-preview-button',
        { label: 'preview' }
      )

      const backButton = component.querySelector(
        '.js-app-c-govspeak-editor__back-button'
      )

      backButton.dispatchEvent(new Event('click'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'govspeak-editor',
        'pressed-preview-button',
        { label: 'edit' }
      )
    })

    it('generates form data correctly', function () {
      const formData = module.generateFormData('some text')

      expect(Array.from(formData.entries())).toEqual([
        ['body', 'some text'],
        ['authenticity_token', 'a-csrf-token'],
        ['alternative_format_provider_id', '11'],
        ['image_ids[]', '1'],
        ['image_ids[]', '2'],
        ['image_ids[]', '3'],
        ['image_ids[]', '4'],
        ['attachment_ids[]', '5'],
        ['attachment_ids[]', '6'],
        ['attachment_ids[]', '7'],
        ['attachment_ids[]', '8']
      ])
    })
  })

  describe('with visual editor', function () {
    beforeEach(function () {
      const visualEditorButton = document.createElement('button')
      visualEditorButton.classList.add(
        'js-app-c-govspeak-editor__visual-editor-button'
      )
      visualEditorButton.innerText = 'Visual editor'
      component.appendChild(visualEditorButton)

      module = new GOVUK.Modules.GovspeakEditor(component)
      module.init()

      spyOn(module, 'getCsrfToken').and.returnValue('a-csrf-token')

      jasmine.Ajax.install()
    })

    afterEach(function () {
      jasmine.Ajax.uninstall()
    })

    it('renders component correctly', function () {
      expect(
        component.querySelector('.js-app-c-govspeak-editor__preview-button')
      ).toHaveClass('app-c-govspeak-editor__preview-button--show')

      expect(
        component.querySelector(
          '.js-app-c-govspeak-editor__visual-editor-button'
        )
      ).toHaveClass('app-c-govspeak-editor__visual-editor-button--show')
    })

    it('hides textarea when visual editor button clicked', function () {
      const visualEditorButton = component.querySelector(
        '.js-app-c-govspeak-editor__visual-editor-button'
      )
      const backButton = component.querySelector(
        '.js-app-c-govspeak-editor__back-button'
      )
      const textareaSection = component.querySelector(
        '.app-c-govspeak-editor__textarea'
      )
      const visualEditor = component.querySelector(
        '.app-c-govspeak-editor__visual-editor'
      )

      expect(textareaSection).not.toHaveClass(
        'app-c-govspeak-editor__textarea--hidden'
      )

      visualEditorButton.dispatchEvent(new Event('click'))

      expect(textareaSection).toHaveClass(
        'app-c-govspeak-editor__textarea--hidden'
      )
      expect(visualEditorButton).not.toHaveClass(
        'app-c-govspeak-editor__visual-editor--show'
      )
      expect(backButton).toHaveClass('app-c-govspeak-editor__back-button--show')
      expect(visualEditor).toHaveClass('app-c-govspeak-editor__visual-editor--show')
    })
  })
})
