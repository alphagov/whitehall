// Loading the monaco editor using ecmascript modules from esm.sh
// This code is tricky to load from npm because it comprises lots of files which need to be bundled together.
// esm.sh solves this problem nicely, but does introduce a dependency on the esm.sh CDN being up and available.
import * as monaco from 'https://esm.sh/monaco-editor@0.52.0'
import workerFactory from 'https://esm.sh/monaco-editor/esm/vs/editor/editor.worker?worker'

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function YamlEditor(module) {
    this.module = module
  }

  YamlEditor.prototype.init = function () {
    self.MonacoEnvironment = {
      getWorker() {
        return workerFactory()
      }
    }
    // NOTE: This is currently very specifically overriding the body field
    //       in the edit edition form. If we actually wanted a YamlEditor,
    //       we would probably want it to be more general than this.
    //
    //       This should just be temporary code for the landing pages, while
    //       we work out a CMS though. So for now it's okay to be specific.
    const form = this.module.querySelector('form#edit_edition')
    const outerContainer = form?.querySelector(
      '.app-c-govspeak-editor:has(#edition_body)'
    )
    const innerContainer = outerContainer?.querySelector(
      '.app-c-govspeak-editor__textarea'
    )

    const previewButtonWrapper = form?.querySelector(
      '.app-c-govspeak-editor__preview-button-wrapper'
    )
    const textArea = innerContainer?.querySelector('#edition_body')
    const value = textArea?.value
    if (!value) {
      console.warn(
        'YamlEditor: DOM structure did not match expectations, falling back to doing nothing'
      )
      return
    }

    const monacoHostDiv = document.createElement('div')
    monacoHostDiv.style.width = '100%'
    monacoHostDiv.style.height = '600px'
    monacoHostDiv.style.border = '1px solid grey'

    // Hide the govspeak editor
    innerContainer.style.display = 'none'

    // Hide the preview button
    // NOTE: hiding the wrapper rather than the button, as govspeak-editor.js shows / hides the button itself
    if (previewButtonWrapper) {
      previewButtonWrapper.style.display = 'none'
    }

    // Append the editor host div to the outer container
    outerContainer.appendChild(monacoHostDiv)

    // Initialise the editor
    const editor = monaco.editor.create(monacoHostDiv, {
      value,
      language: 'yaml',
      minimap: { enabled: false },
      scrollBeyondLastLine: false,
      automaticLayout: true
    })
    const model = editor.getModel()

    form.addEventListener('formdata', (e) =>
      e.formData.set('edition[body]', model.getValue())
    )
  }

  Modules.YamlEditor = YamlEditor
})(window.GOVUK.Modules)
