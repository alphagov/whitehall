describe('GOVUK.DocumentFilter', function () {
  var container, filterForm, filterResults, feedLinks, resultsSummary, originalHistoryEnabled, originalHistoryPushState

  var ajaxData = {
    'next_page?': true,
    next_page: 2,
    next_page_url: '/next-page-url',
    next_page_web_url: '/next-page-url',

    prev_page_url: '/prev-page-url',
    prev_page_web_url: '/prev-page-url',
    'more_pages?': true,
    total_pages: 5,

    atom_feed_url: '/atom-feed',
    email_signup_url: '/email-signups',
    'results_any?': true,
    total_count: 8,
    result_type: 'publication',
    results: [
      {
        result: {
          id: 1,
          type: 'document-type',
          title: 'document-title',
          url: '/document-path',
          organisations: 'organisation-name-1, organisation-name-2',
          topics: 'topic-name-1, topic-name-2',
          field_of_operation: 'place-of-war'
        },
        index: 1
      },
      {
        result: {
          id: 2,
          type: 'document-type-2',
          title: 'document-title-2',
          url: '/document-path-2',
          organisations: 'organisation-name-2, organisation-name-3',
          publication_collections: 'collection-1'
        },
        index: 2
      }
    ]
  }

  beforeEach(function () {
    originalHistoryEnabled = window.GOVUK.support.history
    originalHistoryPushState = history.pushState
    history.pushState = function (state, title, url) {
      return true
    }

    container = $('<div />')
    filterForm = $('<form id="document-filter" action="/foo/bar">' +
      '<input type="submit" />' +
      '<select id="departments" multiple="multiple">' +
      '<option value="all" selected="selected">All</option>' +
      '<option value="dept1">Dept1</option>' +
      '<option value="dept2">Dept2</option>' +
      '</select>' +
      '<input type="radio" id="direction_before">' +
      '<input type="radio" id="direction_after" value="after" checked="checked"> ' +
      '<input type="text" id="keywords" value=""> ' +
      '</form>')
    filterResults = $('<div class="js-filter-results" />')
    feedLinks = $('<div class="feeds"><a class="feed">feed</a> <a class="email-signup">email</a></div>')
    resultsSummary = $('<div class="filter-results-summary"></div>')

    container.append(filterForm, filterResults, feedLinks, resultsSummary)
    $(document.body).append(container)
  })

  afterEach(function () {
    window.GOVUK.support.history = originalHistoryEnabled
    history.pushState = originalHistoryPushState

    container.remove()
  })

  it('should render mustache template from ajax data', function () {
    spyOn($.fn, 'mustache').and.returnValue(true)

    GOVUK.documentFilter.renderTable(ajaxData)

    expect($.fn.mustache).toHaveBeenCalledWith(jasmine.any(String), ajaxData)
  })

  it('should show message when ajax data is empty', function () {
    GOVUK.documentFilter.renderTable({ 'results_any?': false })

    expect(filterResults.find('js-document-list').length).toEqual(0)
    expect(filterResults.find('.no-results').length).toEqual(1)
  })

  it('should show message when ajax data is empty', function () {
    GOVUK.documentFilter.renderTable({ 'results_any?': false })

    expect(filterResults.find('js-document-list').length).toEqual(0)
    expect(filterResults.find('.no-results').length).toEqual(1)
  })

  it('should update the atom feed url', function () {
    expect(feedLinks.find('a[href="/atom-feed"]').length).toEqual(0)

    GOVUK.documentFilter.updateAtomFeed(ajaxData)

    expect(feedLinks.find('a[href="/atom-feed"]').length).toEqual(1)
  })

  it('should update the email signup url', function () {
    expect(feedLinks.find('a[href="/email-signups"]').length).toEqual(0)

    GOVUK.documentFilter.updateEmailSignup(ajaxData)

    expect(feedLinks.find('a[href="/email-signups"]').length).toEqual(1)
  })

  it('should make an ajax request on form submission to obtain filtered results', function () {
    filterForm.enableDocumentFilter()

    spyOn(jQuery, 'ajax')
    filterForm.trigger('submit')

    expect(jQuery.ajax).toHaveBeenCalled()
  })

  it('should send ajax request using json form of url in form action', function () {
    filterForm.enableDocumentFilter()

    spyOn(jQuery, 'ajax')

    filterForm.attr('action', '/specialist')

    filterForm.trigger('submit')

    expect(jQuery.ajax).toHaveBeenCalledWith('/specialist.json', jasmine.any(Object))
  })

  it('should send filter form parameters in ajax request', function () {
    filterForm.enableDocumentFilter()

    spyOn(jQuery, 'ajax')

    filterForm.append($('<select name="foo"><option value="bar" /></select>'))

    filterForm.trigger('submit')

    expect(jQuery.ajax).toHaveBeenCalledWith(jasmine.any(String), jasmine.objectContaining({
      data: [{ name: 'foo', value: 'bar' }]
    }))
  })

  it('should render results based on successful ajax response', function () {
    jasmine.Ajax.withMock(function () {
      filterForm.enableDocumentFilter()
      GOVUK.analytics = { trackPageview: function () {} }

      filterForm.trigger('submit')

      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(ajaxData)
      })

      expect(filterResults.find('.document-row').length).toEqual(2)
      expect(filterResults.find('.document-row .document-collections').text()).toEqual('collection-1')
      expect(filterResults.find('.document-row .topics').text()).toEqual('topic-name-1, topic-name-2')
      expect(filterResults.find('.document-row .field-of-operation').text()).toEqual('place-of-war')
    })
  })

  it('should fire analytics on successful ajax response', function () {
    jasmine.Ajax.withMock(function () {
      filterForm.enableDocumentFilter()
      GOVUK.analytics = { trackPageview: function () {} }

      spyOn(GOVUK.analytics, 'trackPageview')
      filterForm.trigger('submit')

      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(ajaxData)
      })
      expect(GOVUK.analytics.trackPageview).toHaveBeenCalled()
    })
  })

  it('should apply hide class to feed on ajax call', function () {
    jasmine.Ajax.withMock(function () {
      filterForm.enableDocumentFilter()

      filterForm.trigger('submit')
      expect(feedLinks.is('.js-hidden')).toBeTruthy()

      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(ajaxData)
      })

      expect(feedLinks.is('.js-hidden')).toBeFalsy()
    })
  })

  describe('currentPageState', function () {
    it('should include the current results', function () {
      filterForm.enableDocumentFilter()
      var resultsContent = '<p>Test content</p>'
      filterResults.html(resultsContent)
      expect(GOVUK.documentFilter.currentPageState().html).toEqual(resultsContent)
    })

    it('should include the state of any select boxes', function () {
      filterForm.enableDocumentFilter()
      expect(GOVUK.documentFilter.currentPageState().selected).toEqual([{ id: 'departments', value: ['all'], title: ['All'] }])
    })

    it('should include the state of any radio buttons', function () {
      filterForm.enableDocumentFilter()
      expect(GOVUK.documentFilter.currentPageState().checked).toEqual([{ id: 'direction_after', value: 'after' }])
    })

    it('should include the state of any text inputs', function () {
      filterForm.enableDocumentFilter()
      var searchText = 'my example search'
      filterForm.find('#keywords').val(searchText)
      expect(GOVUK.documentFilter.currentPageState().text).toEqual([{ id: 'keywords', value: searchText }])
    })
  })

  describe('onPopState', function () {
    it('should restore the state as specified in the event', function () {
      filterForm.enableDocumentFilter()
      var event = {
        state: {
          html: '<p>Old content</p>',
          selected: [{ id: 'departments', value: ['dept1'] }],
          text: [{ id: 'keywords', value: ['some search'] }],
          checked: ['direction_before']
        }
      }
      GOVUK.documentFilter.onPopState(event)
      expect(filterResults.html()).toEqual(event.state.html)
      expect(filterForm.find('#departments').val()).toEqual(['dept1'])
      expect(filterForm.find('#keywords').val()).toEqual('some search')
      expect(filterForm.find('#direction_before:checked')).toBeTruthy()
    })
  })

  it('should record initial page state in browser history', function () {
    var oldPageState = window.GOVUK.documentFilter.currentPageState
    window.GOVUK.documentFilter.currentPageState = function () { return 'INITIALSTATE' }

    spyOn(history, 'replaceState')
    filterForm.enableDocumentFilter()

    expect(history.replaceState).toHaveBeenCalledWith('INITIALSTATE', null)

    window.GOVUK.documentFilter.currentPageState = oldPageState
  })

  it('should update browser location on successful ajax response', function () {
    jasmine.Ajax.withMock(function () {
      filterForm.enableDocumentFilter()

      var oldPageState = window.GOVUK.documentFilter.currentPageState
      window.GOVUK.documentFilter.currentPageState = function () { return 'CURRENTSTATE' }

      spyOn(history, 'pushState')
      filterForm.attr('action', '/specialist')
      filterForm.append($('<select name="foo"><option value="bar" /></select>'))

      filterForm.trigger('submit')

      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(ajaxData)
      })

      expect(history.pushState).toHaveBeenCalledWith('CURRENTSTATE', null, '/specialist?foo=bar')

      window.GOVUK.documentFilter.currentPageState = oldPageState
    })
  })

  it('should store new table html on successful ajax response', function () {
    jasmine.Ajax.withMock(function () {
      filterForm.enableDocumentFilter()
      spyOn(history, 'pushState')

      filterForm.trigger('submit')
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(ajaxData)
      })

      expect(history.pushState).toHaveBeenCalledWith(
        jasmine.objectContaining({ html: jasmine.any(String) }),
        null,
        '/foo/bar?'
      )
    })
  })

  it('should not enable ajax filtering if browser does not support HTML5 History API', function () {
    var oldHistory = window.GOVUK.support.history
    window.GOVUK.support.history = function () { return false }

    filterForm.enableDocumentFilter()

    spyOn(jQuery, 'ajax')

    filterForm.attr('action', 'javascript:void(0)')
    filterForm.trigger('submit')

    expect(jQuery.ajax).not.toHaveBeenCalled()
    window.GOVUK.support.history = oldHistory
  })

  it('should create live count value', function () {
    window.GOVUK.documentFilter.$form = filterForm

    var data = { total_count: 1337 }

    window.GOVUK.documentFilter.liveResultSummary(data)
    expect(resultsSummary.text()).toMatch('1,337 results')
  })

  it('should update selections to match filters', function () {
    window.GOVUK.documentFilter.$form = filterForm

    var data = { total_count: 1337 }
    var formStatus = {
      selected: [
        {
          title: ['my-title'],
          id: 'topics',
          value: ['my-value']
        }
      ],
      text: [
        {
          title: ['from-date'],
          id: 'from_date',
          value: ['from-date']
        },
        {
          title: ['to-date'],
          id: 'to_date',
          value: ['to-date']
        }
      ]
    }

    spyOn(GOVUK.documentFilter, 'currentPageState').and.returnValue(formStatus)

    window.GOVUK.documentFilter.liveResultSummary(data, formStatus)

    expect(resultsSummary.find('.topics-selections strong').text()).toMatch('my-title')
    expect(resultsSummary.find('.topics-selections a').attr('data-val')).toEqual('my-value')
    expect(resultsSummary.text()).toMatch(/after.from-date/)
    expect(resultsSummary.text()).toMatch(/before.to-date/)
  })

  it('should request removal from document filters', function () {
    resultsSummary.append('<a href="#" data-field="topics" data-val="something">hello</a>')

    spyOn(GOVUK.documentFilter, 'removeFilters')

    filterForm.enableDocumentFilter()

    resultsSummary.find('a').click()

    expect(GOVUK.documentFilter.removeFilters).toHaveBeenCalledWith('topics', 'something')
  })

  it('should remove selection from apropriate filter', function () {
    filterForm.find('option[value="dept1"]').attr('selected', 'selected')

    expect(filterForm.find('select option[value="dept1"]:selected').length).toEqual(1)
    GOVUK.documentFilter.removeFilters('departments', 'dept1')
    expect(filterForm.find('select option[value="dept1"]:selected').length).toEqual(0)
  })

  it('should select first item in filter if no item would be selected', function () {
    filterForm.find('option').removeAttr('selected')
    filterForm.find('option[value="dept1"]').attr('selected', 'selected')

    expect(filterForm.find('select option:selected').length).toEqual(1)
    GOVUK.documentFilter.removeFilters('departments', 'dept1')
    expect(filterForm.find('select option:first-child:selected').length).toEqual(1)
  })

  describe('_numberWithDelimiter', function () {
    it('should add commas', function () {
      expect(GOVUK.documentFilter._numberWithDelimiter(10)).toEqual('10')
      expect(GOVUK.documentFilter._numberWithDelimiter(1000)).toEqual('1,000')
      expect(GOVUK.documentFilter._numberWithDelimiter(1000000)).toEqual('1,000,000')
    })
  })

  describe('_pluralize', function () {
    it('pluralizes basic words', function () {
      expect(GOVUK.documentFilter._pluralize('badger', 0)).toEqual('badgers')
      expect(GOVUK.documentFilter._pluralize('badger', 1)).toEqual('badger')
      expect(GOVUK.documentFilter._pluralize('badger', 2)).toEqual('badgers')
    })

    it('pluralizes words ending in y', function () {
      expect(GOVUK.documentFilter._pluralize('fly', 0)).toEqual('flies')
      expect(GOVUK.documentFilter._pluralize('fly', 1)).toEqual('fly')
      expect(GOVUK.documentFilter._pluralize('fly', 2)).toEqual('flies')
    })
  })
})
