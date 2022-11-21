describe('GOVUK.Modules.LocaleSwitcher', function () {
  var form, localeSwitcher

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-module', 'LocaleSwitcher')
    form.setAttribute('data-rtl-locales', 'ar dr fa he pa-pk ps ur yi')

    form.innerHTML = `
      <form>
        <div class="attachment-form__title">
          <input id="attachment_title">
        </div>

        <select id="attachment_locale">
          <option value="">All languages</option>
          <option value="ar">العربيَّة</option>
          <option value="en">English</option>
        </select>

        <div class="attachment-form__body">
          <textarea></textarea>
        </div>
      </form>
    `

    localeSwitcher = new GOVUK.Modules.LocaleSwitcher(form)
    localeSwitcher.init()
  })

  it('should add the correct class to the appropriate elements when the laguage select element is changed', function () {
    var select = form.querySelector('#attachment_locale')
    var title = form.querySelector('.attachment-form__title')
    var body = form.querySelector('.attachment-form__body')

    select.value = 'ar'
    select.dispatchEvent(new Event('change'))

    expect(title.classList).toContain('attachment-form__title--right-to-left')
    expect(body.classList).toContain('attachment-form__body--right-to-left')

    select.value = 'en'
    select.dispatchEvent(new Event('change'))

    expect(title.classList).not.toContain('attachment-form__title--right-to-left')
    expect(body.classList).not.toContain('attachment-form__body--right-to-left')
  })
})
