describe('GOVUK.Modules.LocaleSwitcher', function () {
  var form, localeSwitcher

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-module', 'LocaleSwitcher')
    form.setAttribute('data-rtl-locales', 'ar dr fa he pa-pk ps ur yi')

    form.innerHTML = `
      <form>
        <div class="app-view-attachments__form-title">
          <input id="attachment_title">
        </div>

        <select id="attachment_locale">
          <option value="">All languages</option>
          <option value="ar">العربيَّة</option>
          <option value="en">English</option>
        </select>

        <div class="app-view-attachments__form-body">
          <div class="app-c-govspeak-editor__textarea">
            <textarea></textarea>
          </div>
          <div class="app-c-govspeak-editor__preview"></div>
        </div>
      </form>
    `

    localeSwitcher = new GOVUK.Modules.LocaleSwitcher(form)
    localeSwitcher.init()
  })

  it('should add the correct value for the `dir` attribute on the appropriate elements when the laguage select element is changed', function () {
    var select = form.querySelector('#attachment_locale')
    var title = form.querySelector('.app-view-attachments__form-title input')
    var body = form.querySelector('.app-view-attachments__form-body .app-c-govspeak-editor__textarea textarea')
    var preview = form.querySelector('.app-view-attachments__form-body .app-c-govspeak-editor__preview')

    select.value = 'ar'
    select.dispatchEvent(new Event('change'))

    expect(title.getAttribute('dir')).toEqual('rtl')
    expect(body.getAttribute('dir')).toEqual('rtl')
    expect(preview.getAttribute('dir')).toEqual('rtl')

    select.value = 'en'
    select.dispatchEvent(new Event('change'))

    expect(title.getAttribute('dir')).toBeNull()
    expect(body.getAttribute('dir')).toBeNull()
    expect(preview.getAttribute('dir')).toBeNull()
  })
})
