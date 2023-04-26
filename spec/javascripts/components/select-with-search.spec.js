describe('GOVUK.Modules.SelectWithSearch', function () {
  var component, module

  function getOptions () {
    var items = component.querySelectorAll('.choices__list .choices__item--choice')
    return Array.from(items).map((item) => (item.textContent.trim()))
  }

  // Simulate a user selecting an option. This will trigger a "change" event.
  function selectOption (value) {
    var event = new MouseEvent('mousedown')
    component.querySelector(`[data-choice][data-value="${CSS.escape(value)}"]`).dispatchEvent(event)
  }

  describe('with a simple select', () => {
    beforeEach(function () {
      component = document.createElement('div')
      component.innerHTML = `
        <label for="example">Choose a colour</label>
        <select id="example">
          <option value="red">Red</option>
          <option value="green">Green</option>
          <option value="blue">Blue</option>
        </select>
      `
      module = new GOVUK.Modules.SelectWithSearch(component)
      module.init()
    })

    it('initialises Choices.js', function () {
      expect(component.querySelector('.choices[data-type="select-one"]')).toBeTruthy()
    })

    it('does not reorder the provided options', () => {
      expect(getOptions()).toEqual(['Red', 'Green', 'Blue'])
    })

    it('shows a search field', () => {
      expect(component.querySelector('input[type=search]').placeholder).toEqual('Search in list')
    })
  })

  describe('simple select which can be left blank', () => {
    beforeEach(function () {
      component = document.createElement('div')
      component.innerHTML = `
        <label for="example">Choose a colour</label>
        <select id="example">
          <option value=""></option>
          <option value="red">Red</option>
          <option value="green">Green</option>
          <option value="blue">Blue</option>
        </select>
      `
      module = new GOVUK.Modules.SelectWithSearch(component)
      module.init()
    })

    it('shows a "Select one" placeholder', () => {
      expect(component.querySelector('.choices__placeholder').textContent).toEqual('Select one')
    })
  })

  describe('with grouped options', () => {
    beforeEach(function () {
      component = document.createElement('div')
      component.innerHTML = `
        <label for="example">Choose a city</label>
        <select id="example">
          <optgroup label="England">
            <option value="bath">Bath</option>
            <option value="bristol">Bristol</option>
            <option value="london">London</option>
            <option value="manchester">Manchester</option>
          </optgroup>
          <optgroup label="Ireland">
            <option value="bangor">Bangor</option>
            <option value="belfast">Belfast</option>
          </optgroup>
          <optgroup label="Scotland">
            <option value="dundee">Dundee</option>
            <option value="edinburgh">Edinburgh</option>
            <option value="glasgow">Glasgow</option>
          </optgroup>
          <optgroup label="Wales">
            <option value="cardiff">Cardiff</option>
            <option value="swansea">Swansea</option>
          </optgroup>
        </select>
      `
      module = new GOVUK.Modules.SelectWithSearch(component)
      module.init()
    })

    it('renders groups and options', () => {
      var list = component.querySelector('.choices__list[role=listbox]')
      expect(list.querySelectorAll('.choices__group').length).toEqual(4)
      expect(list.querySelectorAll('.choices__item--choice').length).toEqual(11)
    })
  })

  describe('with tracking enabled', () => {
    var setup = function ({ category, label = false }) {
      spyOn(GOVUK.analytics, 'trackEvent')

      component = document.createElement('div')

      component.dataset.trackCategory = category
      if (label) component.dataset.trackLabel = label

      component.innerHTML = `
        <label for="example">Choose a colour</label>
        <select id="example">
          <option value=""></option>
          <option value="red">Red</option>
          <option value="green">Green</option>
          <option value="blue">Blue</option>
        </select>
      `
      module = new GOVUK.Modules.SelectWithSearch(component)
      module.init()
    }

    it('tracks event when an option is selected', () => {
      setup({ category: 'Some category', label: 'Some label' })

      selectOption('red')

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'Some category',
        'Red',
        { label: 'Some label' }
      )

      selectOption('blue')

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'Some category',
        'Blue',
        { label: 'Some label' }
      )

      expect(GOVUK.analytics.trackEvent).not.toHaveBeenCalledWith(
        jasmine.any(String),
        'Green',
        jasmine.any(Object)
      )
    })

    it('works when label is not provided', () => {
      setup({ category: 'Some other category' })
      selectOption('red')
      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'Some other category',
        'Red',
        {}
      )
    })
  })
})
