require 'test_helper'

class HistoricAppointmentsHelperTest < ActionView::TestCase

  test '#historical_fact returns the fact as a heading/paragraph pair' do
    assert_equal '<h3>Born</h3><p>2nd May 1979</p>', historical_fact('Born', '2nd May 1979')
  end

  test '#historical_fact returns nothing if the text is blank' do
    assert_nil historical_fact('Born', '')
    assert_nil historical_fact('Born', nil)
  end
end
