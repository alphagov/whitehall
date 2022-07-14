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

  test "it presents a valid placeholder content item" do
    assert_valid_against_publisher_schema @presented_content, "placeholder"
  end

  test "it delegates the content id" do
    assert_equal @operational_field.content_id, @presented_operational_field.content_id
  end

  test "it presents the name as title" do
    assert_equal "Operational Field name", @presented_content[:title]
  end

  test "it presents the description" do
    assert_equal "Operational Field description", @presented_content[:description]
  end

  test "it presents the base_path" do
    assert_equal "/government/fields-of-operation/operational-field-name", @presented_content[:base_path]
  end

  test "it presents the publishing_app as whitehall" do
    assert_equal "whitehall", @presented_content[:publishing_app]
  end

  test "it presents the rendering_app as whitehall-frontend" do
    assert_equal "whitehall-frontend", @presented_content[:rendering_app]
  end

  test "it presents the schema_name as placeholder" do
    assert_equal "placeholder", @presented_content[:schema_name]
  end

  test "it presents the document type as field_of_operation" do
    assert_equal "field_of_operation", @presented_content[:document_type]
  end

  test "it presents the global process wide locale as the locale of the operational_field" do
    assert_equal "en", @presented_content[:locale]
  end

  test "it presents empty details" do
    assert_empty @presented_content[:details]
  end
end
