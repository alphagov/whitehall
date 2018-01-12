require 'test_helper'

class HistoricAppointmentsHelperTest < ActionView::TestCase
  test '#historical_fact returns the fact as a heading/paragraph pair' do
    assert_equal '<h3>Born</h3><p>2nd May 1979</p>', historical_fact('Born', '2nd May 1979')
  end

  test '#historical_fact returns nothing if the text is blank' do
    assert_nil historical_fact('Born', '')
    assert_nil historical_fact('Born', nil)
  end

  test '#previous_dates_in_office returns a year range for the period the person was appointment to the role' do
    role_appointment = create(:role_appointment, started_at: Time.zone.parse("2001-01-01 00:00:00"), ended_at: Time.zone.parse("2011-01-01 00:00:00"))
    assert_equal "2001 to 2011", previous_dates_in_office(role_appointment.role, role_appointment.person)
  end

  test '#previous_dates_in_office returns comma separated year ranges when the person has been appointed to that role multiple times' do
    role_appointment_1 = create(:role_appointment, started_at: Time.zone.parse("2001-01-01 00:00:00"), ended_at: Time.zone.parse("2005-01-01 00:00:00"))
    role_appointment_2 = create(:role_appointment, role: role_appointment_1.role, person: role_appointment_1.person, started_at: Time.zone.parse("2008-01-01 00:00:00"), ended_at: Time.zone.parse("2011-01-01 00:00:00"))
    assert_equal "2008 to 2011, 2001 to 2005", previous_dates_in_office(role_appointment_1.role, role_appointment_1.person)
  end
end
