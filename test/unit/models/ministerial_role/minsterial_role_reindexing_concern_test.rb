require 'test_helper'

class MinisterialRoleReindexingConcernTest < ActiveSupport::TestCase
  test 'should reindex all ministerial roles when a person is updated' do
    person = create(:person)

    MinisterialRole.expects(:reindex_all)

    person.forename = 'Jim'
    person.save
  end

  test 'should reindex all ministerial roles when an organisation is updated' do
    organisation = create(:organisation)

    MinisterialRole.expects(:reindex_all)

    organisation.name = 'Ministry of Funk'
    organisation.save
  end

  test 'should reindex all ministerial roles when a role appointment is created' do
    role_appointment = build(:ministerial_role_appointment)

    MinisterialRole.expects(:reindex_all)

    role_appointment.save
  end

  test 'should reindex all ministerial roles when a role appointment is updated' do
    role_appointment = create(:ministerial_role_appointment)
    person = create(:person)

    MinisterialRole.expects(:reindex_all)

    role_appointment.person = person
    role_appointment.save
  end

  test 'should reindex all ministerial roles when a role appointment is destroyed' do
    role_appointment = create(:ministerial_role_appointment)

    MinisterialRole.expects(:reindex_all)

    role_appointment.destroy
  end

  test 'should reindex all ministerial roles when an organisation role is created' do
    organisation_role = build(:organisation_role)

    MinisterialRole.expects(:reindex_all)

    organisation_role.save
  end

  test 'should reindex all ministerial roles when an organisation role is updated' do
    organisation_role = create(:organisation_role)
    organisation = create(:organisation)

    MinisterialRole.expects(:reindex_all)

    organisation_role.organisation = organisation
    organisation_role.save
  end

  test 'should reindex all ministerial roles when an organisation role is destroyed' do
    organisation_role = create(:organisation_role)

    MinisterialRole.expects(:reindex_all)

    organisation_role.destroy
  end
end
