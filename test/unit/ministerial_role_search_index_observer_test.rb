require 'test_helper'

class MinisterialRoleSearchIndexObserverTest < ActiveSupport::TestCase
  test 'should reindex all ministerial roles when a person is updated' do
    person = create(:person)

    search_index_data = stub('search index data')
    MinisterialRole.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    person.forename = 'Jim'
    person.save
  end

  test 'should reindex all ministerial roles when an organisation is updated' do
    organisation = create(:organisation)

    search_index_data = stub('search index data')
    MinisterialRole.stubs(:search_index).returns(search_index_data)
    Rummageable.stubs(:index) # ignore the update to the organisation index
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    organisation.name = 'Ministry of Funk'
    organisation.save
  end

  test 'should not reindex all ministerial roles when an organisation is updated if observer is disabled' do
    organisation = create(:organisation)

    search_index_data = stub('search index data')
    MinisterialRole.stubs(:search_index).returns(search_index_data)
    Rummageable.stubs(:index).with(has_entry("format" => "organisation"), anything) # ignore the update to the organisation index
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path).never

    organisation.name = 'Ministry of Funk'
    MinisterialRoleSearchIndexObserver.while_disabled do
      organisation.save
    end
  end

  test 'should reindex all ministerial roles when a role appointment is created' do
    role_appointment = build(:ministerial_role_appointment)

    search_index_data = stub('search index data')
    MinisterialRole.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    role_appointment.save
  end

  test 'should reindex all ministerial roles when a role appointment is updated' do
    role_appointment = create(:ministerial_role_appointment)
    person = create(:person)

    search_index_data = stub('search index data')
    MinisterialRole.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    role_appointment.person = person
    role_appointment.save
  end

  test 'should reindex all ministerial roles when a role appointment is destroyed' do
    role_appointment = create(:ministerial_role_appointment)

    search_index_data = stub('search index data')
    MinisterialRole.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    role_appointment.destroy
  end

  test 'should reindex all ministerial roles when an organisation role is created' do
    organisation_role = build(:organisation_role)

    search_index_data = stub('search index data')
    MinisterialRole.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    organisation_role.save
  end

  test 'should reindex all ministerial roles when an organisation role is updated' do
    organisation_role = create(:organisation_role)
    organisation = create(:organisation)

    search_index_data = stub('search index data')
    MinisterialRole.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    organisation_role.organisation = organisation
    organisation_role.save
  end

  test 'should reindex all ministerial roles when an organisation role is destroyed' do
    organisation_role = create(:organisation_role)

    search_index_data = stub('search index data')
    MinisterialRole.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    organisation_role.destroy
  end
end
