class ContentBlockManager::DetailsValidator < ActiveModel::Validator
  attr_reader :edition

  def validate(edition)
    @edition = edition
    errors = validate_with_schema(edition)
    errors.each do |e|
      if e["type"] == "required"
        add_blank_errors(e)
      elsif e["type"] == "format"
        add_format_errors(e)
      end
    end
  end

  def add_blank_errors(error)
    missing_keys = error.dig("details", "missing_keys") || []
    missing_keys.each do |k|
      edition.errors.add("details_#{k}", :blank)
    end
  end

  def add_format_errors(error)
    key = error["data_pointer"].delete_prefix("/")
    format = error["schema"]["format"]
    message = format.present? ? "is an invalid #{format.humanize}" : "is invalid"
    edition.errors.add("details_#{key}", :invalid, message:)
  end

  def validate_with_schema(edition)
    # Fetch the details and remove any blank fields (JSONSchema classes an empty string as valid,
    # unless a specific format has been specified)
    details = edition.details.compact_blank
    schemer = JSONSchemer.schema(edition.schema.body)
    schemer.validate(details)
  end
end
