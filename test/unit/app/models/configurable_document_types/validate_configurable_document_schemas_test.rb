require "test_helper"

class ValidateConfigurableDocumentSchemasTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  test "validates that all configurable document schemas are valid according to the schema" do
    document_type_files = Dir.glob(Rails.root.join("app/models/configurable_document_types/*.json"))

    document_type_files.each do |file_path|
      document = JSON.parse(File.read(file_path))

      errors = SchemaValidator.for(document)

      assert errors.empty?, "Schema validation errors for #{File.basename(file_path)}:\n#{errors.join("\n")}"
    end
  end

  context "validates root level mandatory fields" do
    %w[title description].each do |key|
      it "will cause a validation error if not defined" do
        document = JSON.parse(File.read("test/fixtures/test_schema.json"))
        assert SchemaValidator.for(document).empty?
        document.delete(key)
        assert_equal SchemaValidator.for(document).first, "object at root is missing required properties: #{key}"
      end
    end
  end
end
