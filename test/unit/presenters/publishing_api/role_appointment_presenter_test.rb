require 'test_helper'

class PublishingApi::RoleAppointmentPresenterTest < ActionView::TestCase
  def present(model_instance, options = {})
    PublishingApi::RoleAppointmentPresenter.new(model_instance, options)
  end

  test 'presenter is valid against role appointment schema' do
    role_appointment = create(:role_appointment)

    presented_item = present(role_appointment)
    assert_valid_against_schema(presented_item.content, 'role_appointment')
  end

  test 'presents a role appointment ready for adding to the Publishing API' do
    person = create(:person)
    role = create(:role)
    role_appointment = create(
      :role_appointment,
      person: person,
      role: role
    )

    expected_hash = {
      title: "#{person.name} - #{role.name}",
      schema_name: 'role_appointment',
      document_type: 'role_appointment',
      locale: 'en',
      publishing_app: 'whitehall',
      public_updated_at: role.updated_at,
      update_type: 'major',
      details: {}
    }
    expected_links = {
      person: [person.content_id],
      role: [role.content_id],
    }

    presented_item = present(role_appointment)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal role_appointment.content_id, presented_item.content_id
  end
end
