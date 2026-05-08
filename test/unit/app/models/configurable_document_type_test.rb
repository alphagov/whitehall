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

  test ".allowed_child_document_types_of returns the allowed child document types for a given parent edition" do
    parent_edition = build(:edition, document_id: SecureRandom.uuid, configurable_document_type: "parent_type")
    parent_type = build_configurable_document_type(
      "parent_type",
      {
        "settings" => {
          "allowed_child_document_types" => [
            {
              "document_type" => "child_type",
              # NOTE: we can expand this hash to include other options in future, such as `required` or `allow_multiple`
            },
          ],
        },
      },
    )
    child_type = build_configurable_document_type("child_type")
    ConfigurableDocumentType.setup_test_types(parent_type.merge(child_type))
    child_document_types = ConfigurableDocumentType.allowed_child_document_types_of(parent_edition)
    assert_equal 1, child_document_types.size
    assert_equal "child_type", child_document_types.first.key
  end

  test "#form creates a flattened hash of fields if no form key is provided" do
    configurable_document_type = build_configurable_document_type(
      "test_type",
      {
        "forms" => {
          "test_attribute_1" => {
            "fields" => {
              "field_attribute_1" => {
                "title" => "Field attribute 1",
                "block" => "date_field",
                "translatable" => true,
              },
            },
          },
          "test_attribute_2" => {
            "fields" => {
              "field_attribute_2" => {
                "title" => "Field attribute 2",
                "block" => "govspeak",
                "translatable" => true,
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
    configurable_document_type = build_configurable_document_type(
      "test_type",
      {
        "forms" => {
          "test_attribute_1" => {
            "fields" => {
              "field_attribute_1" => {
                "title" => "Field attribute 1",
                "block" => "date_field",
                "translatable" => true,
              },
            },
          },
          "test_attribute_2" => {
            "fields" => {
              "field_attribute_2" => {
                "title" => "Field attribute 2",
                "block" => "govspeak",
                "translatable" => true,
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
          "translatable" => true,
        },
      },
    }
    assert_equal expected_fields, document_type.form("test_attribute_1")
  end

  test "#presenter returns attributes for a specific service presenter" do
    configurable_document_type = build_configurable_document_type("test_type", {
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

  test "#dynamic_tabs returns only forms marked as dynamic" do
    configurable_document_type = build_configurable_document_type(
      "test_type",
      {
        "forms" => {
          "documents" => {
            "fields" => {
              "body" => { "title" => "Body", "block" => "govspeak" },
            },
          },
          "social_media_accounts" => {
            "label" => "Social media accounts",
            "dynamic" => true,
            "fields" => {
              "social_media_links" => { "title" => "Social media links", "block" => "default_string" },
            },
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")

    assert_equal [
      { "id" => "social_media_accounts", "label" => "Social media accounts" },
    ], document_type.dynamic_tabs
  end

  test "#dynamic_tabs returns empty array when no forms are dynamic" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")

    assert_equal [], document_type.dynamic_tabs
  end

  test "#schema_for_fields returns only the specified fields attributes and validations" do
    configurable_document_type = build_configurable_document_type(
      "test_type",
      {
        "schema" => {
          "attributes" => {
            "body" => { "type" => "string" },
            "social_media_links" => { "type" => "string" },
          },
          "validations" => {
            "presence" => { "attributes" => %w[body] },
            "length" => { "attributes" => %w[social_media_links] },
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")

    result = document_type.schema_for_fields(%w[body])

    assert_equal({ "body" => { "type" => "string" } }, result["attributes"])
    assert_equal({ "presence" => { "attributes" => %w[body] } }, result["validations"])
    assert_not result["attributes"].key?("social_media_links")
    assert_not result["validations"].key?("length")
  end

  test "#schema_for_fields filters the attributes array within a shared validation" do
    configurable_document_type = build_configurable_document_type(
      "test_type",
      {
        "schema" => {
          "attributes" => {
            "field_a" => { "type" => "string" },
            "field_b" => { "type" => "string" },
          },
          "validations" => {
            "presence" => { "attributes" => %w[field_a field_b] },
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")

    result = document_type.schema_for_fields(%w[field_a])

    assert_equal %w[field_a], result["validations"]["presence"]["attributes"]
  end

  test "#schema" do
    configurable_document_type = build_configurable_document_type(
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
end
