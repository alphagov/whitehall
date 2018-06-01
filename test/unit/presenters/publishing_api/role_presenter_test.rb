require 'test_helper'

class PublishingApi::RolePresenterTest < ActionView::TestCase
  def present(model_instance, options = {})
    PublishingApi::RolePresenter.new(model_instance, options)
  end

  test 'presents a Ministerial Role ready for adding to the Publishing API' do
    organisation = create(:organisation)
    role = create(
      :ministerial_role,
      organisations: [organisation],
      responsibilities: 'X and Y'
    )
    current_person = create(:person)
    previous_person = create(:person)
    current_role_appointment = create(
      :role_appointment,
      person: current_person,
      role: role,
      started_at: 1.hour.ago
    )
    previous_role_appointment = create(
      :role_appointment,
      person: previous_person,
      role: role,
      started_at: 1.year.ago,
      ended_at: 1.month.ago
    )

    expected_hash = {
      base_path: "/government/ministers/#{role.slug}",
      title: role.name,
      description: nil,
      schema_name: 'role',
      document_type: 'ministerial_role',
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: role.updated_at,
      routes: [
        {
          path: "/government/ministers/#{role.slug}",
          type: 'exact',
        }
      ],
      redirects: [],
      update_type: 'major',
      details: {
        body: [
          {
            content_type: 'text/html',
            content: 'X and Y',
          },
        ],
        attends_cabinet_type: role.attends_cabinet_type,
        role_payment_type: role.role_payment_type,
        supports_historical_accounts: role.supports_historical_accounts,
      }
    }
    expected_links = {
      ordered_parent_organisations: [organisation.content_id],
      ordered_current_appointments: [current_role_appointment.content_id],
      ordered_previous_appointments: [previous_role_appointment.content_id],
    }

    presented_item = present(role)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal role.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'role')
  end

  test 'presents a Board Member Role ready for adding to the Publishing API' do
    role = create(:board_member_role, responsibilities: 'Y and Z')

    expected_hash = {
      base_path: nil,
      title: role.name,
      description: nil,
      schema_name: 'role',
      document_type: 'board_member_role',
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: role.updated_at,
      routes: [],
      redirects: [],
      update_type: 'major',
      details: {
        body: [
          {
            content_type: 'text/html',
            content: 'Y and Z',
          },
        ],
        attends_cabinet_type: role.attends_cabinet_type,
        role_payment_type: role.role_payment_type,
        supports_historical_accounts: role.supports_historical_accounts,
      }
    }

    presented_item = present(role)

    assert_equal expected_hash, presented_item.content
  end
end
