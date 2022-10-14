describe('GOVUK.StatisticsAnnouncementDateForm', function () {
  var container
  beforeEach(function () {
    container = $('<div>' + inputHtml() + '</div>')
    $(document.body).append(container)
    GOVUK.StatisticsAnnouncementDateForm.init('form_name')
  })

  afterEach(function () {
    container.remove()
  })

  it('renders example dates on initialise', function () {
    expect(container.find('.js-example-exact').text()).toEqual('1 January 2014 12:00am (provisional)')
    expect(container.find('.js-example-one-month').text()).toEqual('January 2014 (provisional)')
    expect(container.find('.js-example-two-month').text()).toEqual('January to February 2014 (provisional)')
  })

  it('updates example dates when dates change', function () {
    container.find('select[name="form_name[release_date(1i)]"]').val('2015')
    container.find('select[name="form_name[release_date(2i)]"]').val('2')
    container.find('select[name="form_name[release_date(3i)]"]').val('9')
    container.find('select[name="form_name[release_date(4i)]"]').val('16')
    container.find('select[name="form_name[release_date(5i)]"]').val('30').trigger('change')
    expect(container.find('.js-example-exact').text()).toEqual('9 February 2015 4:30pm (provisional)')
    expect(container.find('.js-example-one-month').text()).toEqual('February 2015 (provisional)')
    expect(container.find('.js-example-two-month').text()).toEqual('February to March 2015 (provisional)')
  })

  it('updates example dates when dates are confirmed', function () {
    container.find('input[name="form_name[confirmed]"]').val('1').trigger('click')
    expect(container.find('.js-example-exact').text()).toEqual('1 January 2014 12:00am (confirmed)')
    expect(container.find('.js-example-one-month').text()).toEqual('January 2014 (confirmed)')
    expect(container.find('.js-example-two-month').text()).toEqual('January to February 2014 (confirmed)')
  })

  it('handles a two month range over the end of a year, and increments the year', function () {
    container.find('select[name="form_name[release_date(2i)]"]').val('12').trigger('change')
    expect(container.find('.js-example-one-month').text()).toEqual('December 2014 (provisional)')
    expect(container.find('.js-example-two-month').text()).toEqual('December to January 2015 (provisional)')
  })

  it('copes with incorrect dates', function () {
    container.find('select[name="form_name[release_date(2i)]"]').val('2')
    container.find('select[name="form_name[release_date(3i)]"]').val('31').trigger('change')
    expect(container.find('.js-example-exact').text()).toEqual('3 March 2014 12:00am (provisional)')
    expect(container.find('.js-example-one-month').text()).toEqual('March 2014 (provisional)')
  })

  it('updates the date precision to exact when confirming a date', function () {
    container.find('.two-month-date').prop('checked', true)
    container.find('input[name="form_name[confirmed]"]').val('1').trigger('click')

    expect(container.find('.exact-date').prop('checked')).toBeTrue()
    expect(container.find('input[name="form_name[precision]"]').val()).toEqual('0')
  })

  it('hides (and shows) date precision fields when confirming a date', function () {
    container.find('input[name="form_name[confirmed]"]').val('1').trigger('click')
    expect(container.find('.js-label-one-month').is(':visible')).toBeFalse()
    expect($('.js-label-exact').hasClass('block-label-read-only')).toBeTrue()

    container.find('input[name="form_name[confirmed]"]').val('0').trigger('click')
    expect(container.find('.js-label-one-month').is(':visible')).toBeTrue()
    expect($('.js-label-exact').hasClass('block-label-read-only')).toBeFalse()
  })

  function inputHtml () {
    var i
    var html =
      '<select name="form_name[release_date(1i)]">' +
        '<option value="2014"></option>' +
        '<option value="2015"></option>' +
      '</select>' +
      '<select name="form_name[release_date(2i)]">'

    var months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    for (i = 0; i < months.length; i++) {
      html += '<option value=' + (i + 1) + '>' + months[i] + '</option>'
    }

    html += '</select>' +
      '<select name="form_name[release_date(3i)]">'

    for (i = 1; i <= 31; i++) {
      html += '<option value=' + i + '>' + i + '</option>'
    }

    html += '</select>' +
      '<select name="form_name[release_date(4i)]">'

    for (i = 0; i <= 23; i++) {
      var number = i < 10 ? '0' + i.toString() : i.toString()
      html += '<option value=' + number + '>' + number + '</option>'
    }

    html += '</select>' +
      '<select name="form_name[release_date(5i)]">'

    var minutes = ['00', '15', '30', '45']

    for (i = 0; i <= minutes.length; i++) {
      html += '<option value=' + minutes[i] + '>' + minutes[i] + '</option>'
    }

    html += '</select>' +
      '<select name="form_name[release_date(5i)]">' +
      '<input name="form_name[confirmed]" type="checkbox" value="1" />' +
      '<input class="exact-date" name="form_name[precision]" type="radio" value="0" />' +
      '<input class="one-month-date" name="form_name[precision]" type="radio" value="1" />' +
      '<input class="two-month-date" name="form_name[precision]" type="radio" value="2" />' +
      '<span class="js-example-exact"></span>' +
      '<span class="js-example-one-month"></span>' +
      '<span class="js-example-two-month"></span>' +
      '<label class="js-label-one-month"></label>' +
      '<label class="js-label-exact"></label>'

    return html
  }
})
