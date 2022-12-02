describe('GOVUK.Modules.EditionForm', function () {
  var form

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-module', 'EditionForm')

    form.innerHTML = `
    <div class="edition-form__subtype-fields" data-format-advice="{&quot;1&quot;:&quot;\u003cp\u003eNews written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases.\u003c/p\u003e&quot;,&quot;2&quot;:&quot;\u003cp\u003eUnedited press releases as sent to the media, and official statements from the organisation or a minister.\u003c/p\u003e\u003cp\u003eDo \u003cem\u003enot\u003c/em\u003e use for: statements to Parliament. Use the “Speech” format for those.\u003c/p\u003e&quot;,&quot;3&quot;:&quot;\u003cp\u003eGovernment statements in response to media coverage, such as rebuttals and ‘myth busters’.\u003c/p\u003e\u003cp\u003eDo \u003cem\u003enot\u003c/em\u003e use for: statements to Parliament. Use the “Speech” format for those.\u003c/p\u003e&quot;,&quot;4&quot;:&quot;\u003cp\u003eAnnouncements specific to one or more world location. Don’t duplicate news published by another department.\u003c/p\u003e&quot;}">
      <div class="govuk-form-group gem-c-select">
        <label class="govuk-label govuk-label--s" for="edition_news_article_type_id">News article type</label>
        <select name="edition[news_article_type_id]" id="edition_news_article_type_id" class="govuk-select gem-c-select__select--full-width">
          <option value=""></option>
          <option value="1">News story</option>
          <option value="2">Press release</option>
          <option value="3">Government response</option>
          <option value="4">World news story</option></select>
      </div>
    </div>

    <div class="edition-form--locale-fields">
      <input type="checkbox" name="edition[create_foreign_language_only]" id="edition_create_foreign_language_only-0" value="0" checked="checked">

      <select name="edition[primary_locale]" id="edition_primary_locale" class="govuk-select gem-c-select__select--full-width">
        <option value=""></option>
        <option value="ar">العربيَّة (Arabic)</option>
        <option value="az">Azeri (Azeri)</option>
        <option value="be">Беларуская (Belarusian)</option>
      </select>
    </div>
    `
    var editionForm = new GOVUK.Modules.EditionForm(form)
    editionForm.init()
  })

  it('should render subtype guidance based when the subtype format select changes value', function () {
    var select = form.querySelector('#edition_news_article_type_id')

    select.value = '1'
    select.dispatchEvent(new Event('change'))
    var subtypeAdvice = form.querySelector('.edition-form__subtype-format-advice')

    expect(subtypeAdvice.innerHTML).toBe('<strong>Use this subformat for…</strong> <p>News written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases.</p>')
  })

  it('should remove subtype guidance when the subtype format select is unselected', function () {
    var select = form.querySelector('#edition_news_article_type_id')

    select.value = '1'
    select.dispatchEvent(new Event('change'))
    select.value = '0'
    select.dispatchEvent(new Event('change'))

    var subtypeAdvice = form.querySelector('.edition-form__subtype-format-advice')
    expect(subtypeAdvice).toBe(null)
  })

  it('should hide the locale fields when a NewsArticle is not a WorldNewsStory', function () {
    var localeFields = form.querySelector('.edition-form--locale-fields')

    expect(localeFields.style.display).toEqual('none')
  })

  it('should render the locale fields when the WorldNewsStory is selected', function () {
    var select = form.querySelector('#edition_news_article_type_id')

    select.value = '4'
    select.dispatchEvent(new Event('change'))

    var localeFields = form.querySelector('.edition-form--locale-fields')

    expect(localeFields.style.display).toEqual('block')
  })

  it('should reset the locale checkbox and select values when WorldNewsStory is deselected', function () {
    var select = form.querySelector('#edition_news_article_type_id')
    var localeCheckbox = form.querySelector('#edition_create_foreign_language_only-0')
    var localeSelect = form.querySelector('#edition_primary_locale')

    select.value = '4'
    select.dispatchEvent(new Event('change'))

    localeCheckbox.checked = true
    localeCheckbox.value = '1'
    localeSelect.value = 'ar'
    select.value = '1'
    select.dispatchEvent(new Event('change'))

    expect(localeCheckbox.value).toEqual('0')
    expect(localeCheckbox.checked).toEqual(false)
    expect(localeSelect.value).toEqual('')
  })
})
