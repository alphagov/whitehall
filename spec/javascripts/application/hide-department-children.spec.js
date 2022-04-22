describe('GOVUK.hideDepartmentChildren', function () {
  var departments

  beforeEach(function () {
    departments = $(
      '<div class="js-hide-department-children">' +
        '<div class="department">' +
          '<div class="organisations-box">' +
            '<p>child content</p>' +
          '</div>' +
        '</div>' +
      '</div>'
    )
    $(document.body).append(departments)

    this.oldWindowHash = window.location.hash
    window.location.hash = '#department-name'
  })

  afterEach(function () {
    window.location.hash = this.oldWindowHash
    departments.remove()
  })

  it('should create toggle link before department list', function () {
    GOVUK.hideDepartmentChildren.init()
    expect(departments.find('.view-all').length).toEqual(1)
  })

  it('should toggle class when clicking view all link', function () {
    GOVUK.hideDepartmentChildren.init()

    expect(departments.find('.department').hasClass('js-hiding-children')).toBeTrue()
    departments.find('.view-all').click()
    expect(departments.find('.department').hasClass('js-hiding-children')).toBeFalse()
  })

  it('should not toggle class of department with id in window hash', function () {
    departments.find('.organisations-box').append('<span id="department-name"></span>')

    GOVUK.hideDepartmentChildren.init()

    expect(departments.find('.department').hasClass('js-hiding-children')).toBeFalse()
  })
})
