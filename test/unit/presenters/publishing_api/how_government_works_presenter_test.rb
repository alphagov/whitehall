require "test_helper"

class PublishingApi::HowGovernmentWorksPresenterTest < ActiveSupport::TestCase
  setup do
    @current_pm = create(:person)
    pm_role = create(:prime_minister_role)
    create(:role_appointment, person: @current_pm, role: pm_role)

    create(:role_appointment, person: create(:person), role: create(:ministerial_role, cabinet_member: true))
    create(:role_appointment, person: create(:person), role: create(:ministerial_role, cabinet_member: true))
    create(:role_appointment, person: create(:person), role: create(:ministerial_role))
    create(:role_appointment, person: create(:person), role: create(:ministerial_role))
    create(:role_appointment, person: create(:person), role: create(:ministerial_role))

    create(:ministerial_department)
    create(:non_ministerial_department)
    create(:executive_agency)
  end

  test "presents a valid content item" do
    expected_hash = {
      base_path: "/government/how-government-works",
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      schema_name: "how_government_works",
      document_type: "how_government_works",
      title: "How government works",
      description: "About the UK system of government. Understand who runs government, and how government is run.",
      locale: "en",
      routes: [
        {
          path: "/government/how-government-works",
          type: "exact",
        },
      ],
      update_type: "major",
      redirects: [],
      public_updated_at: Time.zone.now,
      details: {
        department_counts: {
          ministerial_departments: 6,
          non_ministerial_departments: 1,
          agencies_and_public_bodies: 1,
        },
        ministerial_role_counts: {
          prime_minister: 1,
          cabinet_ministers: 2,
          other_ministers: 3,
          total_ministers: 6,
        },
      },
    }

    expected_links = {
      current_prime_minister: [
        @current_pm.content_id,
      ],
    }

    presenter = PublishingApi::HowGovernmentWorksPresenter.new

    assert_equal expected_hash, presenter.content
    assert_valid_against_publisher_schema(presenter.content, "how_government_works")

    assert_equal expected_links, presenter.links
    assert_valid_against_links_schema({ links: presenter.links }, "how_government_works")
  end
end
