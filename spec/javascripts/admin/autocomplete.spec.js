describe('GOVUK.autoCompleter', function () {
  var textarea, allSuggestions

  beforeEach(function () {
    textarea = $('<textarea id="my-textarea"></textarea>')
    $(document.body).append(textarea)

    allSuggestions = {
      contacts: [
        { id: 1, title: 'me', summary: 'about me' },
        { id: 2, title: 'you', summary: 'all you, all the time' },
        { id: 3, title: 'them', summary: 'them includes me and you' }
      ]
    }
    GOVUK.autoCompleter.lastValue = undefined
  })

  afterEach(function () {
    textarea.remove()
  })

  describe('getMatch', function () {
    it('should find new match', function () {
      var originalSelectionEnd = GOVUK.autoCompleter.selectionEnd
      GOVUK.autoCompleter.textarea = textarea[0]
      GOVUK.autoCompleter.selectionEnd = function () { return 66 }
      textarea.val('[Contact:me')

      expect(GOVUK.autoCompleter.getMatch()).toEqual({ changed: true, type: 'contacts', match: '[Contact:me', query: 'me', position: 66 })

      GOVUK.autoCompleter.selectionEnd = originalSelectionEnd
    })

    it("should return not changed if value hasn't changed", function () {
      var originalSelectionEnd = GOVUK.autoCompleter.selectionEnd
      GOVUK.autoCompleter.textarea = textarea[0]
      GOVUK.autoCompleter.selectionEnd = function () { return 66 }
      textarea.val('[Contact:me')

      GOVUK.autoCompleter.getMatch()
      expect(GOVUK.autoCompleter.getMatch()).toEqual({ changed: false })

      GOVUK.autoCompleter.selectionEnd = originalSelectionEnd
    })

    it('should return false if no match found', function () {
      var originalSelectionEnd = GOVUK.autoCompleter.selectionEnd
      GOVUK.autoCompleter.textarea = textarea[0]
      GOVUK.autoCompleter.selectionEnd = function () { return 66 }

      expect(GOVUK.autoCompleter.getMatch()).toBe(false)

      GOVUK.autoCompleter.selectionEnd = originalSelectionEnd
    })
  })

  describe('search', function () {
    it('finds correct suggestions', function () {
      var originalSuggestions = GOVUK.autoCompleter.allSuggestions
      GOVUK.autoCompleter.allSuggestions = allSuggestions

      expect(GOVUK.autoCompleter.search('contacts', 'about me')).toEqual([allSuggestions.contacts[0]])
      expect(GOVUK.autoCompleter.search('contacts', '1')).toEqual([allSuggestions.contacts[0]])
      expect(GOVUK.autoCompleter.search('contacts', 'you')).toEqual([allSuggestions.contacts[1], allSuggestions.contacts[2]])
      expect(GOVUK.autoCompleter.search('contacts', 'nothing')).toEqual([])

      GOVUK.autoCompleter.allSuggestions = originalSuggestions
    })
  })

  it('displays matched options', function () {
    var originalSuggestions = GOVUK.autoCompleter.suggestions
    GOVUK.autoCompleter.suggestions = allSuggestions.contacts
    var originalSelector = GOVUK.autoCompleter.$selector
    var selector = $('<div>')
    GOVUK.autoCompleter.$selector = selector

    GOVUK.autoCompleter.displayOptions()

    expect(selector.find('li').length).toEqual(3)
    expect(selector.text().match(/about me/)).toBeTruthy()
    expect(selector.text().match(/all you, all the time/)).toBeTruthy()
    expect(selector.text().match(/them includes me and you/)).toBeTruthy()

    GOVUK.autoCompleter.suggestions = originalSuggestions
    GOVUK.autoCompleter.$selector = originalSelector
  })

  it('sets active selection', function () {
    var originalSuggestions = GOVUK.autoCompleter.suggestions
    GOVUK.autoCompleter.suggestions = allSuggestions.contacts
    var originalSelector = GOVUK.autoCompleter.$selector
    var selector = $('<div>')
    GOVUK.autoCompleter.$selector = selector

    // make 3 options in the selector
    GOVUK.autoCompleter.displayOptions()

    GOVUK.autoCompleter.setActiveSelection(1)
    expect(selector.find('li:eq(1)').hasClass('active')).toBeTruthy()
    expect(selector.find('.active').length).toEqual(1)

    GOVUK.autoCompleter.suggestions = originalSuggestions
    GOVUK.autoCompleter.$selector = originalSelector
  })

  it('sets active selection on mouse move', function () {
    var originalSelector = GOVUK.autoCompleter.$selector
    var selector = $('<div>')
    var li1 = $('<li>')
    var li2 = $('<li>')
    selector.append(li1)
    selector.append(li2)
    GOVUK.autoCompleter.$selector = selector

    expect(li1.hasClass('active')).toBeFalsy()
    GOVUK.autoCompleter.mouseMove({ target: li1 })
    expect(li1.hasClass('active')).toBeTruthy()
    GOVUK.autoCompleter.$selector = originalSelector
  })

  describe('navigateUp', function () {
    it('decrements the current active if it can', function () {
      var originalSelector = GOVUK.autoCompleter.$selector
      GOVUK.autoCompleter.$selector = $('<div> <li></li> <li></li> <li></li> </div>')
      GOVUK.autoCompleter.active = true

      GOVUK.autoCompleter.activeSelector = 2
      GOVUK.autoCompleter.navigateUp()
      expect(GOVUK.autoCompleter.activeSelector).toEqual(1)
      GOVUK.autoCompleter.navigateUp()
      expect(GOVUK.autoCompleter.activeSelector).toEqual(0)
      GOVUK.autoCompleter.navigateUp()
      expect(GOVUK.autoCompleter.activeSelector).toEqual(0)

      GOVUK.autoCompleter.active = false
      GOVUK.autoCompleter.$selector = originalSelector
    })
  })

  describe('navigateDown', function () {
    it('decrements the current active if it can', function () {
      var originalSelector = GOVUK.autoCompleter.$selector
      GOVUK.autoCompleter.$selector = $('<div> <li></li> <li></li> <li></li> </div>')
      GOVUK.autoCompleter.active = true
      GOVUK.autoCompleter.selectorCount = 3

      GOVUK.autoCompleter.activeSelector = 0
      GOVUK.autoCompleter.navigateDown()
      expect(GOVUK.autoCompleter.activeSelector).toEqual(1)
      GOVUK.autoCompleter.navigateDown()
      expect(GOVUK.autoCompleter.activeSelector).toEqual(2)
      GOVUK.autoCompleter.navigateDown()
      expect(GOVUK.autoCompleter.activeSelector).toEqual(2)

      GOVUK.autoCompleter.active = false
      GOVUK.autoCompleter.$selector = originalSelector
    })
  })

  describe('navigateEnter', function () {
    it(' uses the current selected option', function () {
      var originalSuggestions = GOVUK.autoCompleter.suggestions
      GOVUK.autoCompleter.suggestions = allSuggestions.contacts
      GOVUK.autoCompleter.activeSelector = 2
      GOVUK.autoCompleter.active = true
      GOVUK.autoCompleter.textarea = textarea[0]
      GOVUK.autoCompleter.match = {
        position: 10,
        type: 'contacts'
      }
      textarea.val('[Contact:')

      GOVUK.autoCompleter.navigateEnter()
      expect(textarea.val()).toEqual('[Contact:3] ')

      GOVUK.autoCompleter.suggestions = originalSuggestions
    })
  })
})
