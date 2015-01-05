require 'json-schema'

class GovukContentSchema

  class ImproperlyConfiguredError < RuntimeError; end

  VALID_SCHEMA_NAMES = [
    'case_study',
    'unpublishing',
    'redirect',
    'coming_soon',
  ]

  def self.schema_path(schema_name)
    if schema_name == 'test' && Rails.env.test?
      Rails.root.join('lib/govuk_content_schemas/test.json').to_s
    elsif VALID_SCHEMA_NAMES.include? schema_name
      Rails.root.join("#{self.govuk_content_schemas_path}/formats/#{schema_name}/publisher/schema.json").to_s
    end
  end

  def self.govuk_content_schemas_path
    ENV['GOVUK_CONTENT_SCHEMAS_PATH'] || '../govuk-content-schemas'
  end

  class Validator
    def initialize(schema_name, data)
      @schema_path = GovukContentSchema.schema_path(schema_name)
      if !Pathname(@schema_path).dirname.exist?
        raise ImproperlyConfiguredError, "Dependency govuk-content-schemas cannot be found. Ensure it is checked out in the same parent directory as the Whitehall application (see README.md for more details)."
      elif !File.exists?(@schema_path)
        raise ImproperlyConfiguredError, "Schema file not found: #{@schema_path}. Mke sure it is present in govuk-content-schemas."
      end
      @data = data
    end

    def valid?
      errors.empty?
    end

    def errors
      @errors ||= JSON::Validator.fully_validate(@schema_path, @data)
    end
  end
end
