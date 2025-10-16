require "test_helper"
require "json_schemer"

class ValidateConfigurableDocumentSchemasTest < ActiveSupport::TestCase
  test "validates that all configurable document schemas are valid" do
    schema_path = Rails.root.join("public/configurable-document-type.schema.json")
    schema = JSON.parse(File.read(schema_path))
    validator = JSONSchemer.schema(schema)

    document_type_files = Dir.glob(Rails.root.join("app/models/configurable_document_types/*.json"))

    document_type_files.each do |file_path|
      document = JSON.parse(File.read(file_path))
      errors = validator.validate(document).to_a

      assert errors.empty?, "Schema validation errors for #{File.basename(file_path)}:\n#{errors.map { |e| e['error'] }.join("\n")}"
    end
  end
end
