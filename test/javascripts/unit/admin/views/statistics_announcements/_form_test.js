module('admin-statistics-announcement-form', {
  setup: function () {
    $('#qunit-fixture').append(
      '<select name="form_name[release_date(1i)]">' +
        '<option value="2014"></option>' +
        '<option value="2015"></option>' +
      '</select>' +
      '<select name="form_name[release_date(2i)]">' +
        '<option value="1">January</option>' +
        '<option value="2">February</option>' +
        '<option value="3">March</option>' +
        '<option value="4">April</option>' +
        '<option value="5">May</option>' +
        '<option value="6">June</option>' +
        '<option value="7">July</option>' +
        '<option value="8">August</option>' +
        '<option value="9">September</option>' +
        '<option value="10">October</option>' +
        '<option value="11">November</option>' +
        '<option value="12">December</option>' +
      '</select>' +
      '<select name="form_name[release_date(3i)]">' +
        '<option value="1">1</option>' +
        '<option value="2">2</option>' +
        '<option value="3">3</option>' +
        '<option value="4">4</option>' +
        '<option value="5">5</option>' +
        '<option value="6">6</option>' +
        '<option value="7">7</option>' +
        '<option value="8">8</option>' +
        '<option value="9">9</option>' +
        '<option value="10">10</option>' +
        '<option value="11">11</option>' +
        '<option value="12">12</option>' +
        '<option value="13">13</option>' +
        '<option value="14">14</option>' +
        '<option value="15">15</option>' +
        '<option value="16">16</option>' +
        '<option value="17">17</option>' +
        '<option value="18">18</option>' +
        '<option value="19">19</option>' +
        '<option value="20">20</option>' +
        '<option value="21">21</option>' +
        '<option value="22">22</option>' +
        '<option value="23">23</option>' +
        '<option value="24">24</option>' +
        '<option value="25">25</option>' +
        '<option value="26">26</option>' +
        '<option value="27">27</option>' +
        '<option value="28">28</option>' +
        '<option value="29">29</option>' +
        '<option value="30">30</option>' +
        '<option value="31">31</option>' +
      '</select>' +
      '<select name="form_name[release_date(4i)]">' +
        '<option value="00">00</option>' +
        '<option value="01">01</option>' +
        '<option value="02">02</option>' +
        '<option value="03">03</option>' +
        '<option value="04">04</option>' +
        '<option value="05">05</option>' +
        '<option value="06">06</option>' +
        '<option value="07">07</option>' +
        '<option value="08">08</option>' +
        '<option value="09">09</option>' +
        '<option value="10">10</option>' +
        '<option value="11">11</option>' +
        '<option value="12">12</option>' +
        '<option value="13">13</option>' +
        '<option value="14">14</option>' +
        '<option value="15">15</option>' +
        '<option value="16">16</option>' +
        '<option value="17">17</option>' +
        '<option value="18">18</option>' +
        '<option value="19">19</option>' +
        '<option value="20">20</option>' +
        '<option value="21">21</option>' +
        '<option value="22">22</option>' +
        '<option value="23">23</option>' +
      '</select>' +
      '<select name="form_name[release_date(5i)]">' +
        '<option value="00">00</option>' +
        '<option value="15">15</option>' +
        '<option value="30">30</option>' +
        '<option value="45">45</option>' +
      '</select>' +
      '<input name="form_name[confirmed]" type="checkbox" value="1" />' +
      '<input class="qunit-exact-date" name="form_name[precision]" type="radio" value="0" />' +
      '<input class="qunit-one-month-date" name="form_name[precision]" type="radio" value="1" />' +
      '<input class="qunit-two-month-date" name="form_name[precision]" type="radio" value="2" />' +
      '<span class="js-example-exact"></span>' +
      '<span class="js-example-one-month"></span>' +
      '<span class="js-example-two-month"></span>' +
      '<label class="js-label-one-month"></label>' +
      '<label class="js-label-exact"></label>'
    )

    GOVUK.StatisticsAnnouncementDateForm.init('form_name')
  }
})

test('it renders example dates on initialise', function () {
  equal($('.js-example-exact').text(), '1 January 2014 12:00am (provisional)')
  equal($('.js-example-one-month').text(), 'January 2014 (provisional)')
  equal($('.js-example-two-month').text(), 'January to February 2014 (provisional)')
})

test('it updates example dates when dates change', function () {
  $('select[name="form_name[release_date(1i)]"]').val('2015')
  $('select[name="form_name[release_date(2i)]"]').val('2')
  $('select[name="form_name[release_date(3i)]"]').val('9')
  $('select[name="form_name[release_date(4i)]"]').val('16')
  $('select[name="form_name[release_date(5i)]"]').val('30').trigger('change')
  equal($('.js-example-exact').text(), '9 February 2015 4:30pm (provisional)')
  equal($('.js-example-one-month').text(), 'February 2015 (provisional)')
  equal($('.js-example-two-month').text(), 'February to March 2015 (provisional)')
})

test('it updates example dates when dates are confirmed', function () {
  $('input[name="form_name[confirmed]"]').val('1').trigger('click')
  equal($('.js-example-exact').text(), '1 January 2014 12:00am (confirmed)')
  equal($('.js-example-one-month').text(), 'January 2014 (confirmed)')
  equal($('.js-example-two-month').text(), 'January to February 2014 (confirmed)')
})

test('it handles a two month range over the end of a year, and increments the year', function () {
  $('select[name="form_name[release_date(2i)]"]').val('12').trigger('change')
  equal($('.js-example-one-month').text(), 'December 2014 (provisional)')
  equal($('.js-example-two-month').text(), 'December to January 2015 (provisional)')
})

test('its handling of incorrect dates matches rails', function () {
  // Feb 31
  $('select[name="form_name[release_date(2i)]"]').val('2')
  $('select[name="form_name[release_date(3i)]"]').val('31').trigger('change')
  equal($('.js-example-exact').text(), '3 March 2014 12:00am (provisional)')
  equal($('.js-example-one-month').text(), 'March 2014 (provisional)')
})

test('it updates the date precision to exact when confirming a date', function () {
  $('.qunit-two-month-date').prop('checked', true)
  ok($('.qunit-two-month-date').prop('checked'))
  confirmDate()
  ok($('.qunit-exact-date').prop('checked'))
  equal($('input[name="form_name[precision]"]').val(), '0')
})

test('it hides (and shows) date precision fields when confirming a date', function () {
  confirmDate()
  equal($('.js-label-one-month').attr('style').trim(), 'display: none;')
  ok($('.js-label-exact').hasClass('block-label-read-only'))

  unconfirmDate()
  equal($('.js-label-one-month').attr('style').trim(), 'display: inline;')
  ok(!$('.js-label-exact').hasClass('block-label-read-only'))
})

function confirmDate () {
  $('input[name="form_name[confirmed]"]').val('1').trigger('click')
}

function unconfirmDate () {
  $('input[name="form_name[confirmed]"]').val('0').trigger('click')
}
