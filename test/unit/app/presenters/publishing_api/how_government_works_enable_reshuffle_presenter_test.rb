require "test_helper"

class PublishingApi::HowGovernmentWorksEnableReshufflePresenterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

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

  test "presents a valid content item with minimal details and links" do
    expected_hash = {
      base_path: "/government/how-government-works",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "government-frontend",
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
        reshuffle_in_progress: true,
      },
    }

    expected_links = {
      current_prime_minister: [],
    }

    presenter = PublishingApi::HowGovernmentWorksEnableReshufflePresenter.new

    assert_equal expected_hash, presenter.content
    assert_valid_against_publisher_schema(presenter.content, "how_government_works")

    assert_equal expected_links, presenter.links
    assert_valid_against_links_schema({ links: presenter.links }, "how_government_works")
  end
end
