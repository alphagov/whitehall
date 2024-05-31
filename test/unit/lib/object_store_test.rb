require "test_helper"

class ObjectStoreTest < ActiveSupport::TestCase
  setup do
    @items = ObjectStore.instance_variable_get :@items
    ObjectStore.instance_variable_set :@items, nil

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

  teardown do
    ObjectStore.instance_variable_set :@items, @items
  end

  test "#items casts configuration to objects" do
    items = ObjectStore.items

    assert_equal items[0].name, "type_1"
    assert_equal items[0].field_names, %w[my_field]

    assert_equal items[1].name, "type_2"
    assert_equal items[1].field_names, %w[some_field other_field]

    assert_equal items[0].fields.size, 1

    assert_equal items[0].fields[0].name, "my_field"
    assert_equal items[0].fields[0].type, "string"
    assert_equal items[0].fields[0].required?, true

    assert_equal items[1].fields.size, 2

    assert_equal items[1].fields[0].name, "some_field"
    assert_equal items[1].fields[0].type, "string"
    assert_equal items[1].fields[0].required?, true

    assert_equal items[1].fields[1].name, "other_field"
    assert_equal items[1].fields[1].type, "string"
    assert_equal items[1].fields[1].required?, false
  end

  test "#item_type_by_name returns an item type" do
    assert_equal ObjectStore.item_type_by_name("type_1").name, "type_1"
    assert_equal ObjectStore.item_type_by_name("type_2").name, "type_2"
  end

  test "#item_type_by_name raises an error when an item is missing" do
    err = assert_raises ObjectStore::UnknownItemType do
      ObjectStore.item_type_by_name("other_type")
    end
    assert_match(/other_type/, err.message)
  end

  test "#item_types returns all configured item types" do
    assert_equal ObjectStore.item_types, %w[type_1 type_2]
  end
end
