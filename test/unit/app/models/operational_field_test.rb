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
    assert_not operational_field.valid?
  end

  test "is invalid without a unique name" do
    existing_operational_field = create(:operational_field)
    new_operational_field = build(:operational_field, name: existing_operational_field.name)
    assert_not new_operational_field.valid?
  end

  test "sets a slug from the field name" do
    field = create(:operational_field, name: "Field Name")
    assert_equal "field-name", field.slug
  end

  test "does not change the slug when the field name changes" do
    field = create(:operational_field, name: "Field Name")
    field.update!(name: "New Field Name")
    assert_equal "field-name", field.slug
  end

  test "should send the fields of operation index page to publishing api when a field of operation is created" do
    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::OperationalFieldsIndexPresenter)

    create(:operational_field)
  end

  test "should send the fields of operation index page to publishing api when a field of operation is updated" do
    field = create(:operational_field, name: "Field Name")

    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::OperationalFieldsIndexPresenter)

    field.update!(name: "New Field Name")
  end

  test "should send the fields of operation index page to publishing api when a field of operation is destroyed" do
    field = create(:operational_field, name: "Field Name")

    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::OperationalFieldsIndexPresenter)

    field.destroy!
  end
end
