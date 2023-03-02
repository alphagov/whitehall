require "test_helper"

class PublishingApi::OperationalFieldPresenterTest < ActiveSupport::TestCase
  setup do
    @operational_field = create(
      :operational_field,
      name: "Operational Field name",
      description: "Operational Field description",
    )

    @presented_operational_field = PublishingApi::OperationalFieldPresenter.new(@operational_field)
    @presented_content = @presented_operational_field.content
  end

  test "presents an operational field" do
    expected_hash = {
      title: "Operational Field name",
      locale: "en",
      publishing_app: "whitehall",
      update_type: "major",
      base_path: "/government/fields-of-operation/operational-field-name",
      details: {},
      document_type: "field_of_operation",
      rendering_app: "whitehall-frontend",
      schema_name: "field_of_operation",
      description: "Operational Field description",
      routes: [
        {
          path: "/government/fields-of-operation/operational-field-name",
          type: "exact",
        },
      ],
    }

    assert_equal expected_hash, @presented_content
    assert_valid_against_publisher_schema @presented_content, "field_of_operation"
  end

  test "it delegates the content id" do
    assert_equal @operational_field.content_id, @presented_operational_field.content_id
  end
end
