require "test_helper"
require "json-schema"

class ValidateConfigurableDocumentSchemasTest < ActiveSupport::TestCase
  test "validates that all configurable document schemas are valid" do
    schema_path = Rails.root.join("public/configurable-document-type.schema.json")
    schema = JSON.parse(File.read(schema_path))

    document_type_files = Dir.glob(Rails.root.join("app/models/configurable_document_types/*.json"))

    document_type_files.each do |file_path|
      document = JSON.parse(File.read(file_path))

      assert_nothing_raised do
        JSON::Validator.validate(schema, document)
      end
    end
  end
end
