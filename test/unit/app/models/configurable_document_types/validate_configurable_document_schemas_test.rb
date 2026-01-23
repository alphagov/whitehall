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

  describe "`SchemaValidator` should validate" do
    let(:document) { JSON.parse(File.read("test/fixtures/test_schema.json")) }

    before do
      assert SchemaValidator.for(document).empty?
    end

    context "that root level mandatory fields are defined" do
      %w[title description].each do |key|
        it "will cause a validation error if not defined" do
          document.delete(key)
          assert_equal SchemaValidator.for(document).first, "object at root is missing required properties: #{key}"
        end
      end
    end

    context "within `settings`" do
      %w[configurable_document_group publishing_api_schema_name publishing_api_document_type rendering_app].each do |key|
        it "the value of `#{key}` should assigned one of its enum values" do
          document["settings"][key] = "not a valid enum value"
          validator = SchemaValidator.new(document)
          enum = validator.schema["properties"]["settings"]["properties"][key]["enum"]
          validator.validate
          assert_equal validator.errors.first, "value at `/settings/#{key}` is not one of: #{enum}"
        end
      end

      context "`base_path_prefix` has been set to" do
        %w[
          /government/history
          /government/news-articles
          /a
          /123
          /path-with-hyphens
          /path.with.dots
          /path/with/multiple/slashes
          /UPPERCASE
          /MixedCase
          /path-123.abc/def
          /government/world-location-news
        ].each do |valid_url|
          it "a valid relative url" do
            document["settings"]["base_path_prefix"] = valid_url
            assert SchemaValidator.for(document).empty?, "Schema should be valid if `settings.base_path_prefix` for valid URL `#{valid_url}`"
          end
        end

        [
          ["government/history", "does not start with /"],
          ["/", "has no characters after initial /"],
        ].each do |invalid_url, error_message|
          it "a url that `#{error_message}" do
            document["settings"]["base_path_prefix"] = invalid_url
            assert_equal SchemaValidator.for(document).first, "string at `settings/base_path_prefix` is not a valid URL"
          end
        end

        (%w[
          _underscore
          @email
          ?query
          #anchor
          %20encoded
          +plus
          (bracket)
        ] + [" space"]).each do |invalid_character|
          it "a url that does not contain a #{invalid_character.match(/[a-z]*/)[0]} character" do
            document["settings"]["base_path_prefix"] += invalid_character
            assert_equal SchemaValidator.for(document).first, "string at `settings/base_path_prefix` is not a valid URL"
          end
        end
      end

      context "when `images`" do
        it "are not enabled then `forms.image` is not defined" do
          document["settings"]["images"]["enabled"] = false
          assert_equal SchemaValidator.for(document).first, "forms/images cannot be defined if settings/images/enabled is `false`"
        end

        it "are enabled then `forms.image` can be defined" do
          document["settings"]["images"]["enabled"] = true
          assert SchemaValidator.for(document).empty?, "Schema should not fail validation if `forms.images` defined and `images` are enabled in `settings`"
        end
      end
    end
  end
end
