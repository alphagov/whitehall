require "test_helper"

class ConfigurableDocumentTypeTest < ActiveSupport::TestCase
  test ".find raises an error if the type is not specified" do
    error = assert_raises(ConfigurableDocumentType::NotFoundError) { ConfigurableDocumentType.find(nil) }
    assert_equal "No document type specified", error.message
  end

  test ".find raises an error if the type is not found" do
    error = assert_raises(ConfigurableDocumentType::NotFoundError) { ConfigurableDocumentType.find("non_existent_type") }
    assert_equal "No document type found for 'non_existent_type'", error.message
  end

  test "#properties_for_edit_screen returns properties for a given edit screen" do
    body_property = {
      "title" => "Body",
      "description" => "The main content of the page",
      "type" => "string",
      "format" => "govspeak",
    }
    another_property = {
      "title" => "Another Property",
      "description" => "Another property for testing",
      "type" => "string",
    }
    image_property = {
      "title" => "Image",
      "description" => "The image for the page",
      "type" => "integer",
      "format" => "image_select",
    }
    configurable_document_type = build_configurable_document_type(
      "test_type",
      {
        "schema" => {
          "properties" => {
            "body" => body_property,
            "another_property" => another_property,
            "image" => image_property,
          },
        },
        "settings" => {
          "edit_screens" => {
            "document" => %w[body another_property],
            "images" => %w[image],
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")

    assert_equal({ "body" => body_property, "another_property" => another_property }, document_type.properties_for_edit_screen("document"))
    assert_equal({ "image" => image_property }, document_type.properties_for_edit_screen("images"))
  end

  test ".convertible_from returns the configurable document types in the same group excluding itself" do
    group_key = "test_group"
    initial_type = build_configurable_document_type(
      "initial_type", {
        "settings" => {
          "configurable_document_group" => group_key,
        },
      }
    )
    new_type = build_configurable_document_type(
      "new_type", {
        "settings" => {
          "configurable_document_group" => group_key,
        },
      }
    )
    other_type = build_configurable_document_type(
      "other_type", {
        "settings" => {
          "configurable_document_group" => "other_group",
        },
      }
    )
    ConfigurableDocumentType.setup_test_types(initial_type.merge(new_type).merge(other_type))
    types_we_can_convert_to = ConfigurableDocumentType.convertible_from("initial_type")
    assert_equal 1, types_we_can_convert_to.size
    assert_equal "new_type", types_we_can_convert_to.first.key
  end
  test "#form creates a flattened hash of fields if no form key is provided" do
    configurable_document_type = build_configurable_document_type_with_forms(
      "test_type",
      {
        "forms" => {
          "test_attribute_1" => {
            "fields" => {
              "field_attribute_1" => {
                "title" => "Field attribute 1",
                "block" => "date_field",
              },
            },
          },
          "test_attribute_2" => {
            "fields" => {
              "field_attribute_2" => {
                "title" => "Field attribute 2",
                "block" => "govspeak",
              },
            },
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")

    assert document_type.form["fields"].key?("field_attribute_1")
    assert document_type.form["fields"].key?("field_attribute_2")
  end

  test "#form returns fields specific to a single form if its key is provided" do
    configurable_document_type = build_configurable_document_type_with_forms(
      "test_type",
      {
        "forms" => {
          "test_attribute_1" => {
            "fields" => {
              "field_attribute_1" => {
                "title" => "Field attribute 1",
                "block" => "date_field",
              },
            },
          },
          "test_attribute_2" => {
            "fields" => {
              "field_attribute_2" => {
                "title" => "Field attribute 2",
                "block" => "govspeak",
              },
            },
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")
    expected_fields = {
      "fields" => {
        "field_attribute_1" => {
          "title" => "Field attribute 1",
          "block" => "date_field",
        },
      },
    }
    assert_equal expected_fields, document_type.form("test_attribute_1")
  end

  test "#presenter returns attributes for a specific service presenter" do
    configurable_document_type = build_configurable_document_type_with_forms("test_type", {
      "presenters" => {
        "service_key" => {
          "field_attribute_1" => "string",
        },
      },
    })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")
    expected_payload = {
      "field_attribute_1" => "string",
    }
    assert_equal expected_payload, document_type.presenter("service_key")
  end

  test "#required_attributes returns an array of required attributes from the schema" do
    configurable_document_type = build_configurable_document_type_with_forms(
      "test_type",
      {
        "schema" => {
          "attributes" => {
            "field_attribute_1" => {
              "type" => "string",
            },
            "field_attribute_2" => {
              "type" => "date",
            },
          },
          "validations" => {
            "presence" => {
              "attributes" => %w[field_attribute_1],
            },
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")

    assert_equal %w[field_attribute_1], document_type.required_attributes
  end

  test "schema with forms" do
    configurable_document_type = build_configurable_document_type_with_forms(
      "test_type",
      {
        "forms" => {},
        "schema" => {
          "attributes" => {
            "field_attribute_1" => {
              "type" => "date",
            },
            "field_attribute_2" => {
              "type" => "date",
            },
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")
    expected_schema = {
      "attributes" => {
        "field_attribute" => {
          "type" => "string",
        },
        "field_attribute_1" => {
          "type" => "date",
        },
        "field_attribute_2" => {
          "type" => "date",
        },
      },
    }
    assert_equal expected_schema, document_type.schema
  end

  test "schema with properties" do
    configurable_document_type = build_configurable_document_type(
      "test_type",
      {
        "schema" => {
          "properties" => {
            "body" => {
              "title" => "Body",
              "description" => "The main content of the page",
              "type" => "string",
            },
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")
    expected_schema = {
      "properties" => {
        "test_attribute" => {
          "title" => "Test Attribute",
          "type" => "string",
        },
        "body" => {
          "title" => "Body",
          "description" => "The main content of the page",
          "type" => "string",
        },
      },
    }
    assert_equal expected_schema, document_type.schema
  end
end
