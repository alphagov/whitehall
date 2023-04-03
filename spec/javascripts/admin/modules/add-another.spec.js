describe('GOVUK.Modules.AddAnother', function () {
  var fixture, addAnother, addButton, removeButton, fields, field0, field1

  beforeEach(function () {
    fixture = document.createElement('div')
    fixture.setAttribute('data-module', 'AddAnother')
    fixture.setAttribute('data-add-text', 'Add another thing')
    fixture.innerHTML = `
      <div class="js-duplicate-fields-set">
        <input type="hidden" name="a[b][0][c]" value="abc"></input>
        <label for="d_e_0_f"></label>
        <input type="text" id="d_e_0_f" name="d[e][0][f]" value="def"></input>
        <label for="g_h_0_i"></label>
        <textarea id="g_h_0_i" name="g[h][0][i]">ghi</textarea>
      </div>
    `

    document.body.append(fixture)

    addAnother = new GOVUK.Modules.AddAnother(fixture)
    addAnother.init()

    addButton = document.querySelector('.add-another__add-button')
  })

  afterEach(function () {
    fixture.innerHTML = ''
  })

  it('should add an "Add" button to the container when the component is initialised', function () {
    expect(addButton).toBeTruthy()
    expect(addButton.textContent).toBe('Add another thing')
  })

  it('should add new fields with the correct values when the "Add" button is clicked', function () {
    window.GOVUK.triggerEvent(addButton, 'click')

    field0 = document.querySelectorAll('.js-duplicate-fields-set')[0]
    field1 = document.querySelectorAll('.js-duplicate-fields-set')[1]

    expect(document.querySelectorAll('.js-duplicate-fields-set').length).toBe(2)
    expect(field0.querySelector('input[type="hidden"]').value).toBe('abc')
    expect(field1.querySelector('input[type="hidden"]').value).toBe('')
    expect(field0.querySelector('input[type="text"]').value).toBe('def')
    expect(field1.querySelector('input[type="text"]').value).toBe('')
    expect(field0.querySelector('textarea').value).toBe('ghi')
    expect(field1.querySelector('textarea').value).toBe('')
  })

  it('should move focus to the first relevant field in the new set when the "Add" button is clicked', function () {
    window.GOVUK.triggerEvent(addButton, 'click')

    expect(document.activeElement).toBe(document.querySelector('input[name="d[e][1][f]"]'))
  })

  it('should increment the id/name/for values of the added fields', function () {
    window.GOVUK.triggerEvent(addButton, 'click')

    field0 = document.querySelectorAll('.js-duplicate-fields-set')[0]
    field1 = document.querySelectorAll('.js-duplicate-fields-set')[1]

    expect(field0.querySelector('input[type="hidden"]').getAttribute('name')).toBe('a[b][0][c]')
    expect(field1.querySelector('input[type="hidden"]').getAttribute('name')).toBe('a[b][1][c]')
    expect(field0.querySelectorAll('label')[0].getAttribute('for')).toBe('d_e_0_f')
    expect(field1.querySelectorAll('label')[0].getAttribute('for')).toBe('d_e_1_f')
    expect(field0.querySelector('input[type="text"]').getAttribute('id')).toBe('d_e_0_f')
    expect(field1.querySelector('input[type="text"]').getAttribute('id')).toBe('d_e_1_f')
    expect(field0.querySelector('input[type="text"]').getAttribute('name')).toBe('d[e][0][f]')
    expect(field1.querySelector('input[type="text"]').getAttribute('name')).toBe('d[e][1][f]')
    expect(field0.querySelectorAll('label')[1].getAttribute('for')).toBe('g_h_0_i')
    expect(field1.querySelectorAll('label')[1].getAttribute('for')).toBe('g_h_1_i')
    expect(field0.querySelector('textarea').getAttribute('id')).toBe('g_h_0_i')
    expect(field1.querySelector('textarea').getAttribute('id')).toBe('g_h_1_i')
    expect(field0.querySelector('textarea').getAttribute('name')).toBe('g[h][0][i]')
    expect(field1.querySelector('textarea').getAttribute('name')).toBe('g[h][1][i]')
  })

  it('should add a "Remove" button to each set of fields when new fields are created', function () {
    window.GOVUK.triggerEvent(addButton, 'click')

    field0 = document.querySelectorAll('.js-duplicate-fields-set')[0]
    field1 = document.querySelectorAll('.js-duplicate-fields-set')[1]

    expect(field0.querySelector('.add-another__remove-button')).toBeTruthy()
    expect(field1.querySelector('.add-another__remove-button')).toBeTruthy()
  })

  it('should add a hidden input field with the appropriate attributes for each removed set when the "Remove" button is clicked', function () {
    var hiddenField

    window.GOVUK.triggerEvent(addButton, 'click')
    window.GOVUK.triggerEvent(addButton, 'click')

    removeButton = document.querySelectorAll('.add-another__remove-button')[0]

    window.GOVUK.triggerEvent(removeButton, 'click')

    hiddenField = document.querySelector('.js-hidden-destroy') || null

    expect(hiddenField).toBeTruthy()
    expect(hiddenField.id).toBe('d_e_0__destroy')
    expect(hiddenField.name).toBe('d[e][0][_destroy]')
    expect(hiddenField.value).toBe('true')
  })

  it('should remove the appropriate field when the "Remove" button is clicked', function () {
    window.GOVUK.triggerEvent(addButton, 'click')

    fields = document.querySelectorAll('.js-duplicate-fields-set')
    removeButton = fields[0].querySelector('.add-another__remove-button')

    window.GOVUK.triggerEvent(removeButton, 'click')

    field0 = document.querySelectorAll('.js-duplicate-fields-set')[0]
    field1 = document.querySelectorAll('.js-duplicate-fields-set')[1]

    expect(document.querySelectorAll('.js-duplicate-fields-set').length).toBe(1)
    expect(field0).toBeTruthy()
    expect(field1).toBeFalsy()
  })

  // This test is not working since removing the resetting of values on remove
  // Consider if it's actually required
  it('should move focus to the first field when any "Remove" button is clicked', function () {
    window.GOVUK.triggerEvent(addButton, 'click')
    window.GOVUK.triggerEvent(addButton, 'click')
    removeButton = document.querySelectorAll('.add-another__remove-button')[0]

    window.GOVUK.triggerEvent(removeButton, 'click')

    expect(document.activeElement).toBe(document.querySelector('input[name="d[e][1][f]"]'))
  })
})
