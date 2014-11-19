require 'json-schema'

class GovukContentSchema

  VALID_SCHEMA_NAMES = [
    'case_study',
  ]
  VALID_SCHEMA_NAMES << 'test' if Rails.env.test?

  def self.schema_path(schema_name)
    if VALID_SCHEMA_NAMES.include? schema_name
      Rails.root.join("lib/govuk_content_schemas/#{schema_name}.json").to_s
    end
  end

  class Validator
    def initialize(schema_name, data)
      @schema_path = GovukContentSchema.schema_path(schema_name)
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
