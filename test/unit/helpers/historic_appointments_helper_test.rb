require 'test_helper'

class HistoricAppointmentsHelperTest < ActionView::TestCase

  test '#historical_fact returns the fact as a heading/paragraph pair' do
    assert_equal '<h3>Born</h3><p>2nd May 1979</p>', historical_fact('Born', '2nd May 1979')
  end

  test '#historical_fact returns nothing if the text is blank' do
    assert_nil historical_fact('Born', '')
    assert_nil historical_fact('Born', nil)
  end

  test '#historic_appointment_path generates the historic appointment path for the role and person' do
    person = create(:person, forename: 'Gordo', surname: 'Bloom')
    pm_role = create(:ministerial_role, name: 'Prime Minister')
    chancellor_role = create(:ministerial_role, name: 'Chancellor of the Exchequer')

    assert_equal '/government/history/past-prime-ministers/gordo-bloom', historic_appointment_path(pm_role, person)
    assert_equal '/government/history/past-chancellors/gordo-bloom', historic_appointment_path(chancellor_role, person)
  end
end
