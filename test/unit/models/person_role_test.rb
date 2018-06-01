require 'test_helper'

class PersonRoleTest < ActiveSupport::TestCase
  test "creating a new role and person republishes the linked organisation" do
    test_object = create(:organisation)
    role = create(:role, organisations: [test_object])
    person = create(:person)
    role_appointment = build(:role_appointment, person: person, role: role)
    Whitehall::PublishingApi.expects(:publish_async).with(test_object).once
    Whitehall::PublishingApi.expects(:publish_async).with(role_appointment).once
    role_appointment.save!
  end

  test "updating an existing person republishes the linked organisation" do
    test_object = create(:organisation)
    role = create(:role, organisations: [test_object])
    person = create(:person)
    create(:role_appointment, person: person, role: role)
    person.reload
    person.forename = "Test"
    Whitehall::PublishingApi.expects(:publish_async).with(person).once
    Whitehall::PublishingApi.expects(:publish_async).with(test_object).once
    person.save!
  end

  test "updating an existing role republishes the linked organisation" do
    test_object = create(:organisation)
    role = create(:role, organisations: [test_object])
    person = create(:person)
    create(:role_appointment, person: person, role: role)
    person.reload
    role.cabinet_member = true
    Whitehall::PublishingApi.expects(:publish_async).with(role).once
    Whitehall::PublishingApi.expects(:publish_async).with(test_object).once
    role.save!
  end
end
