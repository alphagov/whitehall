require "test_helper"

class ValidateConfigurableDocumentSchemasTest < ActiveSupport::TestCase
  test "validates that all configurable document schemas are valid according to the schema" do
    document_type_files = Dir.glob(Rails.root.join("app/models/configurable_document_types/*.json"))

    document_type_files.each do |file_path|
      document = JSON.parse(File.read(file_path))

      errors = SchemaValidator.for(document)

      assert errors.empty?, "Schema validation errors for #{File.basename(file_path)}:\n#{errors.join("\n")}"
    end
  end
end
