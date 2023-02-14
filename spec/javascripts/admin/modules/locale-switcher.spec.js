describe('GOVUK.Modules.LocaleSwitcher', function () {
  var form, localeSwitcher

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-module', 'LocaleSwitcher')
    form.setAttribute('data-rtl-locales', '["ar", "dr", "fa", "he", "pa-pk", "ps", "ur", "yi"]')

    form.innerHTML = `
      <form>
        <div class="js-locale-switcher-selector">
          <select>
            <option value="">All languages</option>
            <option value="ar">العربيَّة</option>
            <option value="en">English</option>
          </select>
        </div>

        <div class="js-locale-switcher-field">
          <input id="input"></input>
        </div>

        <div class="js-locale-switcher-field">
          <textarea id="textarea"></textarea>
        </div>

        <div>
          <div id="customElement" class="js-locale-switcher-custom"></div>
        </div>
      </form>
    `

    localeSwitcher = new GOVUK.Modules.LocaleSwitcher(form)
    localeSwitcher.init()
  })

  it('should add the correct value for the `dir` attribute on the appropriate elements when the laguage select element is changed', function () {
    var select = form.querySelector('.js-locale-switcher-selector')
    var input = form.querySelector('#input')
    var textarea = form.querySelector('#textarea')
    var customElement = form.querySelector('#customElement')

    select.value = 'ar'
    select.dispatchEvent(new Event('change'))

    expect(input.getAttribute('dir')).toEqual('rtl')
    expect(textarea.getAttribute('dir')).toEqual('rtl')
    expect(customElement.getAttribute('dir')).toEqual('rtl')

    select.value = 'en'
    select.dispatchEvent(new Event('change'))

    expect(input.getAttribute('dir')).toBeNull()
    expect(textarea.getAttribute('dir')).toBeNull()
    expect(customElement.getAttribute('dir')).toBeNull()
  })
})
