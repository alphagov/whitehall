require "test_helper"

class ValidateConfigurableDocumentSchemasTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "SchemaValidator" do
    let(:document) { JSON.parse(File.read("test/fixtures/test_schema.json")) }

    before do
      assert SchemaValidator.for(document).empty?
    end

    it "validates that all configurable document schemas are valid according to the schema" do
      document_type_files = Dir.glob(Rails.root.join("app/models/configurable_document_types/*.json"))

      document_type_files.each do |file_path|
        document = JSON.parse(File.read(file_path))

        errors = SchemaValidator.for(document)

        assert errors.empty?, "Schema validation errors for #{File.basename(file_path)}:\n#{errors.join("\n")}"
      end
    end

    context "root level mandatory fields" do
      %w[title description].each do |key|
        it "will cause a validation error if not defined" do
          document.delete(key)
          assert_equal SchemaValidator.for(document).first, "object at root is missing required properties: #{key}"
        end
      end
    end

    context "within `settings`" do
      %w[configurable_document_group publishing_api_schema_name publishing_api_document_type rendering_app].each do |key|
        it "validates `#{key}` has been assigned an enum value defined in the schema" do
          document["settings"][key] = "not a valid enum value"
          validator = SchemaValidator.new(document)
          enum = validator.schema["properties"]["settings"]["properties"][key]["enum"]
          validator.validate
          assert_equal validator.errors.first, "value at `/settings/#{key}` is not one of: #{enum}"
        end
      end
    end
  end
end
