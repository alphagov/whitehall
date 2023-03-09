require "test_helper"

class PublishingApi::OperationalFieldsIndexPresenterTest < ActiveSupport::TestCase
  setup do
    create(:operational_field)
    create(:operational_field)
  end

  test "presents a valid content item" do
    expected_hash = {
      base_path: "/government/fields-of-operation",
      details: {},
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      schema_name: "fields_of_operation",
      document_type: "fields_of_operation",
      title: "Fields of operation",
      locale: "en",
      routes: [
        {
          path: "/government/fields-of-operation",
          type: "exact",
        },
      ],
      update_type: "major",
      redirects: [],
      public_updated_at: Time.zone.now,
    }

    expected_links = {
      fields_of_operation: [
        OperationalField.first.content_id,
        OperationalField.second.content_id,
      ],
    }

    presenter = PublishingApi::OperationalFieldsIndexPresenter.new

    assert_equal expected_hash, presenter.content
    assert_valid_against_publisher_schema(presenter.content, "fields_of_operation")

    assert_equal expected_links, presenter.links
    assert_valid_against_links_schema({ links: presenter.links }, "fields_of_operation")
  end
end
