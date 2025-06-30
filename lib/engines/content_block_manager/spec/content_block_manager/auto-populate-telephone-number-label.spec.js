describe('GOVUK.Modules.AutoPopulateTelephoneNumberLabel', function () {
  let fixture, autoPopulateTelephoneNumberLabel

  const fieldset = `<fieldset>
          <select name="content_block/edition[details][telephones][telephone_numbers][][type]">
             <option value="">Select</option>
             <option value="1">1</option>
             <option value="2">2</option>
          </select>
          <input name="content_block/edition[details][telephones][telephone_numbers][][label]" />
      </fieldset>`

  beforeEach(function () {
    fixture = document.createElement('div')
    fixture.innerHTML = `<div id="firstFieldset">${fieldset}</div>`

    document.body.append(fixture)

    autoPopulateTelephoneNumberLabel =
      new GOVUK.Modules.AutoPopulateTelephoneNumberLabel(fixture)
    autoPopulateTelephoneNumberLabel.init()
  })

  afterEach(function () {
    fixture.innerHTML = ''
  })

  it('should auto-populate the label field when the type is selected', function () {
    const select = document.querySelector(
      'select[name="content_block/edition[details][telephones][telephone_numbers][][type]"]'
    )
    select.selectedIndex = 2

    window.GOVUK.triggerEvent(select, 'change')

    const valueField = document.querySelector(
      'input[name="content_block/edition[details][telephones][telephone_numbers][][label]"]'
    )

    expect(valueField.value).toEqual('2')

    select.selectedIndex = 1
    window.GOVUK.triggerEvent(select, 'change')

    expect(valueField.value).toEqual('1')
  })

  it('should work when new items are appended', function (done) {
    const addAnotherButton = document.createElement('a')
    addAnotherButton.classList.add('js-add-another__add-button')
    addAnotherButton.href = '#'
    addAnotherButton.innerText = 'Add another'

    fixture.append(addAnotherButton)

    const additionalFieldset = document.createElement('div')
    additionalFieldset.id = 'additionalFieldset'
    additionalFieldset.innerHTML = fieldset

    fixture.append(additionalFieldset)

    setTimeout(() => {
      window.GOVUK.triggerEvent(addAnotherButton, 'click')

      const select = document.querySelector('#additionalFieldset select')
      select.selectedIndex = 2

      window.GOVUK.triggerEvent(select, 'change')

      const valueField = document.querySelector('#additionalFieldset input')

      expect(valueField.value).toEqual('2')
      done()
    }, 10)
  })
})
