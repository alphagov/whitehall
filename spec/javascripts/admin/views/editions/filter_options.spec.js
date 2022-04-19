describe('GOVUK.FilterOptions', function () {
  var container

  beforeEach(function () {
    container = $(
      '<div>' +
        '<form class="filter-options js-editions-filter-form" action="/government/admin/editions" method="get">' +
          '<div id="title_filter" class="filter-grouping">' +
            '<label for="search_title">Title or slug</label>' +
            '<div class="btn-enter-wrapper">' +
              '<input type="search" value="hello world" placeholder="Search title" name="title" id="search_title">' +
              '<input type="submit" value="enter" name="commit" class="btn-enter js-btn-enter js-hidden">' +
            '</div>' +
          '</div>' +
          '<div id="state_filter" class="filter-grouping">' +
            '<label for="state">State</label>' +
            '<select name="state" id="state" class="chzn-select-no-search" style="display: none;">' +
              '<option selected="selected" value="active">All states</option>' +
              '<option value="draft">Draft</option>' +
              '<option value="published">Published</option>' +
            '</select>' +
          '</div>' +
        '</form>' +
        '<div id="search_results"></div>' +
      '</div>'
    )

    $(document.body).append(container)
  })

  afterEach(function () {
    container.remove()
  })

  it('sends an ajax request when results are updated', function () {
    var filter = new GOVUK.FilterOptions({
      filter_form: container.find('.filter-options'),
      search_results: container.find('#search_results')
    })

    spyOn(jQuery, 'ajax')
    filter.updateResults(true)

    expect(jQuery.ajax).toHaveBeenCalledWith(jasmine.objectContaining({
      url: '/government/admin/editions',
      method: 'get',
      data: 'title=hello+world&state=active'
    }))
  })

  it('renders the request response to #search_results', function () {
    var filter = new GOVUK.FilterOptions({
      filter_form: container.find('.filter-options'),
      search_results: container.find('#search_results')
    })

    jasmine.Ajax.withMock(function () {
      filter.updateResults(true)

      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        contentType: 'text/html',
        responseText: '<p>Exactly what you wanted</p>'
      })

      expect(container.find('#search_results').text()).toEqual('Exactly what you wanted')
    })
  })

  it('updates results when a select field changes', function () {
    spyOn(GOVUK.FilterOptions.prototype, 'updateResultsWithNoRepeatProtection')
    new GOVUK.FilterOptions({ // eslint-disable-line no-new
      filter_form: container.find('.filter-options'),
      search_results: container.find('#search_results')
    })

    container.find('#state').change()
    expect(GOVUK.FilterOptions.prototype.updateResultsWithNoRepeatProtection).toHaveBeenCalledTimes(1)
  })

  it("shows an enter button when a text input is changed, and then updates results when that's clicked", function () {
    spyOn(GOVUK.FilterOptions.prototype, 'updateResultsWithNoRepeatProtection')
    new GOVUK.FilterOptions({ // eslint-disable-line no-new
      filter_form: container.find('.filter-options'),
      search_results: container.find('#search_results')
    })

    var button = container.find('.btn-enter')

    // CSS would normally hide the button.
    button.hide()

    container.find('#search_title').change()
    expect(button.is(':visible')).toBeTrue()
    button.click()
    expect(button.is(':visible')).toBeFalse()
    expect(GOVUK.FilterOptions.prototype.updateResultsWithNoRepeatProtection).toHaveBeenCalledTimes(1)
  })
})
