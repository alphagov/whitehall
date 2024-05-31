require "test_helper"

class ObjectStoreTest < ActiveSupport::TestCase
  setup do
    @fields = {
      "type_1" => {
        "properties" => {
          "my_field" => {
            "type" => "string",
          },
        },
        "required" => %w[my_field],
      },
      "type_2" => {
        "properties" => {
          "some_field" => {
            "type" => "string",
          },
          "other_field" => {
            "type" => "string",
          },
        },
        "required" => %w[some_field],
      },
    }
    ObjectStore.configure do |config|
      config.fields = @fields
    end
  end

  test "#config_for_item_type returns an item type's configuration" do
    assert_equal ObjectStore.config_for_item_type("type_1"), @fields["type_1"]
    assert_equal ObjectStore.config_for_item_type("type_2"), @fields["type_2"]
  end

  test "#config_for_item_type raises an error when an item is missing" do
    err = assert_raises ObjectStore::UnknownItemType do
      ObjectStore.config_for_item_type("other_type")
    end
    assert_match(/other_type/, err.message)
  end

  test "#fields_for_item_type returns the properties for a field" do
    assert_equal ObjectStore.fields_for_item_type("type_1"), @fields["type_1"]["properties"]
    assert_equal ObjectStore.fields_for_item_type("type_2"), @fields["type_2"]["properties"]
  end

  test "#field_is_required? returns if a field is required for a particular type" do
    assert ObjectStore.field_is_required?("type_1", "my_field")
    assert ObjectStore.field_is_required?("type_2", "some_field")
    assert_equal ObjectStore.field_is_required?("type_2", "other_field"), false
  end

  test "#required_fields_for_item_type returns required fields" do
    assert_equal ObjectStore.required_fields_for_item_type("type_1"), %w[my_field]
    assert_equal ObjectStore.required_fields_for_item_type("type_2"), %w[some_field]
  end

  test "#field_names_for_item_type returns the keys of all fields" do
    assert_equal ObjectStore.field_names_for_item_type("type_1"), %w[my_field]
    assert_equal ObjectStore.field_names_for_item_type("type_2"), %w[some_field other_field]
  end

  test "#item_types returns all configured item types" do
    assert_equal ObjectStore.item_types, %w[type_1 type_2]
  end
end
