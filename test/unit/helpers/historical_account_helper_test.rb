require 'test_helper'

class HistoricalAccountHelperTest < ActionView::TestCase

  test '#historical_fact returns the fact as a heading/paragraph pair' do
    assert_equal '<h3>Born</h3><p>2nd May 1979</p>', historical_fact('Born', '2nd May 1979')
  end

  test '#historical_fact returns nothing if the text is blank' do
    assert_nil historical_fact('Born', '')
    assert_nil historical_fact('Born', nil)
  end

  test '#historical_account_path generates the path for an historical account based on the role and the person' do
    person = create(:person, forename: 'Gordo', surname: 'Bloom')
    pm_role = create(:ministerial_role, name: 'Prime Minister')
    create(:role_appointment, role: pm_role, person: person)
    pm_account = create(:historical_account, roles: [pm_role], person: person)
    assert_equal '/government/history/past-prime-ministers/gordo-bloom', historical_account_path(pm_account)

    chancellor_role = create(:ministerial_role, name: 'Chancellor of the Exchequer')
    create(:role_appointment, role: chancellor_role, person: person)
    chancellor_account = create(:historical_account, roles: [chancellor_role], person: person)
    assert_equal '/government/history/past-chancellors/gordo-bloom', historical_account_path(chancellor_account)
  end

  test '#historical_account_path allows the role used to be overridden so we can link to the appropriate role when there are multiple' do
    person = create(:person, forename: 'Gordo', surname: 'Bloom')
    pm_role = create(:ministerial_role, name: 'Prime Minister')
    create(:role_appointment, role: pm_role, person: person)
    chancellor_role = create(:ministerial_role, name: 'Chancellor of the Exchequer')
    create(:role_appointment, role: chancellor_role, person: person)
    pm_account = create(:historical_account, roles: [pm_role, chancellor_role], person: person)

    assert_equal '/government/history/past-prime-ministers/gordo-bloom', historical_account_path(pm_account)
    assert_equal '/government/history/past-chancellors/gordo-bloom', historical_account_path(pm_account, chancellor_role)
  end
end
