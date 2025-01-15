class ContentBlockManager::DetailsValidator < ActiveModel::Validator
  attr_reader :edition

  BASE_TRANSLATION_PATH = "activerecord.errors.models.content_block_manager/content_block/edition.attributes.details".freeze

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
    root_key = error["data_pointer"].delete_prefix("/").gsub("/", "_")
    missing_keys.each do |k|
      error_key = ["details", root_key, k].compact_blank.join("_")
      edition.errors.add(error_key, I18n.t("#{BASE_TRANSLATION_PATH}.blank", attribute: k.humanize))
    end
  end

  def add_format_errors(error)
    key = error["data_pointer"].delete_prefix("/")
    field = key.split("/").last
    edition.errors.add("details_#{key}", I18n.t("#{BASE_TRANSLATION_PATH}.invalid", attribute: field.humanize))
  end

  def validate_with_schema(edition)
    # Fetch the details and remove any blank fields (JSONSchema classes an empty string as valid,
    # unless a specific format has been specified)
    details = (edition.details || {}).compact_blank.transform_values do |value|
      if value.is_a?(Array)
        value.map(&:compact_blank)
      elsif value.is_a?(Hash)
        value.compact_blank
      else
        value
      end
    end
    schemer = JSONSchemer.schema(edition.schema.body)
    schemer.validate(details)
  end
end
