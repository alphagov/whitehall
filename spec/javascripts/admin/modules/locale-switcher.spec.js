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
          <textarea></textarea>
        </div>
      </form>
    `

    localeSwitcher = new GOVUK.Modules.LocaleSwitcher(form)
    localeSwitcher.init()
  })

  it('should add the correct class to the appropriate elements when the laguage select element is changed', function () {
    var select = form.querySelector('#attachment_locale')
    var title = form.querySelector('.app-view-attachments__form-title')
    var body = form.querySelector('.app-view-attachments__form-body')

    select.value = 'ar'
    select.dispatchEvent(new Event('change'))

    expect(title.classList).toContain('app-view-attachments__form-title--right-to-left')
    expect(body.classList).toContain('app-view-attachments__form-body--right-to-left')

    select.value = 'en'
    select.dispatchEvent(new Event('change'))

    expect(title.classList).not.toContain('app-view-attachments__form-title--right-to-left')
    expect(body.classList).not.toContain('app-view-attachments__form-body--right-to-left')
  })
})
