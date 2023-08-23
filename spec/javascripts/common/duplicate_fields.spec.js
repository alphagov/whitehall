describe('GOVUK.duplicateFields', function () {
  let fieldset

  beforeEach(function () {
    fieldset = $(
      '<fieldset class="js-duplicate-fields">' +
        '<div class="js-duplicate-fields-set">' +
          '<label for="model_1_object">label</label>' +
          '<input type="text" name="model[1][object]" id="model_1_object">' +
        '</div>' +
      '</fieldset>'
    )
    $(document.body).append(fieldset)
  })

  afterEach(function () {
    fieldset.remove()
  })

  it('should insert an add button', function () {
    GOVUK.duplicateFields.init()

    expect(fieldset.find('a.js-add-button').length).toEqual(1)
  })

  it('should insert a button to remove fields', function () {
    GOVUK.duplicateFields.init()

    expect(fieldset.find('div.js-duplicate-fields-set a.js-remove-button').length).toEqual(1)
  })

  it('should create new fields when the add button is clicked', function () {
    GOVUK.duplicateFields.init()

    fieldset.find('a.js-add-button').trigger('click')

    expect(fieldset.find('.js-duplicate-fields-set').length).toEqual(2)
  })

  it('should increment the field index when adding a new item', function () {
    GOVUK.duplicateFields.init()

    fieldset.find('a.js-add-button').trigger('click')

    expect(fieldset.find('.js-duplicate-fields-set').last().find('input').attr('name')).toEqual('model[2][object]')
  })

  it('should update id and for attributes of new fields', function () {
    GOVUK.duplicateFields.init()

    fieldset.find('a.js-add-button').trigger('click')

    const newSet = fieldset.find('.js-duplicate-fields-set').last()
    expect(newSet.find('input').attr('id')).toEqual('model_2_object')
    expect(newSet.find('label').attr('for')).toEqual('model_2_object')
  })

  it('should cope with fields with a second level of index', function () {
    fieldset.find('input')
      .attr('name', 'model[1][attribute][1][object]')
      .attr('id', 'model_1_attribute_1_object')
    fieldset.find('label').attr('for', 'model_1_attribute_1_object')

    GOVUK.duplicateFields.init()

    fieldset.find('a.js-add-button').trigger('click')

    const newSet = fieldset.find('.js-duplicate-fields-set').last()
    expect(newSet.find('input').attr('name')).toEqual('model[1][attribute][2][object]')
    expect(newSet.find('input').attr('id')).toEqual('model_1_attribute_2_object')
    expect(newSet.find('label').attr('for')).toEqual('model_1_attribute_2_object')
  })

  it('should hide the fields when removing', function () {
    GOVUK.duplicateFields.init()
    const set = fieldset.find('.js-duplicate-fields-set').last()

    set.find('a.js-remove-button').trigger('click')

    expect(set.is(':visible')).toBeFalse()
  })

  it('should resets input values when removing', function () {
    GOVUK.duplicateFields.init()
    const set = fieldset.find('.js-duplicate-fields-set').last()

    set.find('input').val('some value')
    set.find('a.js-remove-button').trigger('click')

    expect(set.find('input').val()).toEqual('')
  })

  it('should add a hidden _destroy input when removing', function () {
    GOVUK.duplicateFields.init()
    const set = fieldset.find('.js-duplicate-fields-set').last()

    set.find('a.js-remove-button').trigger('click')

    expect(set.find('input#model_1__destroy').length).toEqual(1)
    expect(set.find('input#model_1__destroy').attr('name')).toEqual('model[1][_destroy]')
    expect(set.find('input#model_1__destroy').val()).toEqual('true')
  })

  describe('when last remaining field set has been "removed"', function () {
    beforeEach(function () {
      GOVUK.duplicateFields.init()
      const set = fieldset.find('.js-duplicate-fields-set').last()
      set.find('a.js-remove-button').trigger('click')
    })

    it('should reset the _destroy input when adding', function () {
      fieldset.find('a.js-add-button').trigger('click')
      const newSet = fieldset.find('.js-duplicate-fields-set').last()

      expect(newSet.find('input#model_2__destroy').val()).toEqual('')
    })

    it('should make the new field set visible when adding', function () {
      fieldset.find('a.js-add-button').trigger('click')
      const newSet = fieldset.find('.js-duplicate-fields-set').last()

      expect(newSet.is(':visible')).toBeTrue()
    })
  })

  describe('when a field set marked for removal', function () {
    let presentFieldset, destroyFieldset

    beforeEach(function () {
      presentFieldset = $('<div class="js-duplicate-fields-set"><label for="model_1_object">label</label><input type="text" name="model[1][object]" id="model_1_object"></div>')
      destroyFieldset = $('<div class="js-duplicate-fields-set"><label for="model_1_object">label</label><input type="text" name="model[1][object]" id="model_1_object"><input class="js-hidden-destroy" type="hidden" name="model[1][_destroy]" id="model_1__destroy" value="true"></div>')

      fieldset.empty().append(presentFieldset, destroyFieldset)
    })

    it('should hide field sets marked for removal', function () {
      GOVUK.duplicateFields.init()

      expect(presentFieldset.is(':visible')).toBeTrue()
      expect(destroyFieldset.is(':visible')).toBeFalse()
    })
  })
})
