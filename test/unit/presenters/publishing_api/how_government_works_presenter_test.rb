require "test_helper"

class PublishingApi::HowGovernmentWorksPresenterTest < ActiveSupport::TestCase
  test "presents a valid content item" do
    expected_hash = {
      base_path: "/government/how-government-works",
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      schema_name: "special_route",
      document_type: "special_route",
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
    }

    presenter = PublishingApi::HowGovernmentWorksPresenter.new

    assert_equal expected_hash, presenter.content
    assert_valid_against_publisher_schema(presenter.content, "special_route")
  end
end
