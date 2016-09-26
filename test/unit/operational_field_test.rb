require "test_helper"

class OperationalFieldTest < ActiveSupport::TestCase
  test "publishes to PublishingApi" do
    assert OperationalField.new.is_a?(PublishesToPublishingApi)
  end

  test "has a content_id when saved" do
    operational_field = create(:operational_field)
    assert operational_field.content_id
  end

  test "is invalid without a name" do
    operational_field = build(:operational_field, name: "")
    refute operational_field.valid?
  end

  test "is invalid without a unique name" do
    existing_operational_field = create(:operational_field)
    new_operational_field = build(:operational_field, name: existing_operational_field.name)
    refute new_operational_field.valid?
  end

  test "sets a slug from the field name" do
    field = create(:operational_field, name: "Field Name")
    assert_equal "field-name", field.slug
  end

  test "does not change the slug when the field name changes" do
    field = create(:operational_field, name: "Field Name")
    field.update_attributes(name: "New Field Name")
    assert_equal "field-name", field.slug
  end
end
