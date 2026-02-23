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

      context "`base_path_prefix` has been set to a valid prefix" do
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
          it "should be considered valid" do
            document["settings"]["base_path_prefix"] = valid_url
            assert SchemaValidator.for(document).empty?, "Schema should be valid if `settings.base_path_prefix` for valid URL `#{valid_url}`"
          end
        end

        [
          "government/history", # does not start with /
          "/", # has no characters after initial /
        ].each do |invalid_url|
          it "is not valid" do
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
          it "is invalid if it contains an invalid character" do
            document["settings"]["base_path_prefix"] += invalid_character
            assert_equal SchemaValidator.for(document).first, "string at `settings/base_path_prefix` is not a valid URL"
          end
        end
      end

      context "validating `images`" do
        it "does not allow `forms.image` to be defined if `settings.images.enabled` is `false`" do
          document["settings"]["images"]["enabled"] = false
          assert_equal SchemaValidator.for(document).first, "forms/images cannot be defined if settings/images/enabled is `false`"
        end

        it "allows `forms.image` to be defined if `settings.images.enabled` is `true`" do
          document["settings"]["images"]["enabled"] = true
          assert SchemaValidator.for(document).empty?, "Schema should not fail validation if `forms.images` defined and `images` are enabled in `settings`"
        end
      end
    end

    context "validating `schema`" do
      it "validates that all defined `attributes` are used within `forms`" do
        document["schema"]["attributes"]["extra_attribute"] = {
          "type" => "string",
        }
        assert_equal SchemaValidator.for(document).first, "Schema has schema attributes extra_attribute that are not used in the forms attribute"
      end

      it "validates that `validations` only reference fields that are defined in `attributes`" do
        document["schema"]["validations"] = {
          "presence" => {
            "attributes" => %w[extra_field],
          },
        }
        assert_equal SchemaValidator.for(document).first, "Schema has properties extra_field in validators that are not defined in schema attributes"
      end
    end

    context "validating `forms`" do
      it "validates that all defined `fields` are also defined in `schema`" do
        document["forms"]["documents"]["fields"]["extra_field"] = {
          "title" => "extra field",
          "description" => "an extra field",
          "block" => "govspeak",
        }
        assert_equal SchemaValidator.for(document).first, "Schema has form fields extra_field that are not defined in schema attributes"
      end

      it "validates that all \"required\" fields have presence validation in the schema" do
        document["forms"]["documents"]["fields"]["body"]["required"] = true
        assert_equal SchemaValidator.for(document).first, "Forms have required fields body that do not have presence validation defined"
      end
    end
  end
end
