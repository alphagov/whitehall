class ContentBlockManager::DetailsValidator < ActiveModel::Validator
  attr_reader :edition

  def validate(edition)
    @edition = edition
    errors = validate_with_schema(edition)
    errors.each do |e|
      if e["type"] == "required"
        add_blank_errors(e)
      elsif %w[format pattern].include?(e["type"])
        add_format_errors(e)
      end
    end
  end

  def add_blank_errors(error)
    missing_keys = error.dig("details", "missing_keys") || []
    missing_keys.each do |k|
      key = key_with_optional_prefix(error, k)
      edition.errors.add(
        "details_#{key}",
        I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.blank", attribute: k.humanize),
      )
    end
  end

  def add_format_errors(error)
    data_pointer = error["data_pointer"].delete_prefix("/")
    field_items = data_pointer.split("/")
    attribute = field_items.last
    key = key_with_optional_prefix(error, nil)
    edition.errors.add(
      "details_#{key}",
      I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.invalid", attribute: attribute.humanize),
    )
  end

  def validate_with_schema(edition)
    # Fetch the details and remove any blank fields (JSONSchema classes an empty string as valid,
    # unless a specific format has been specified)
    details = compact_nested(edition.details)
    schemer = JSONSchemer.schema(edition.schema.body)
    schemer.validate(details)
  end

  def key_with_optional_prefix(error, key)
    if error["data_pointer"].present?
      keys = error["data_pointer"].split("/")
      [
        keys[1],
        *keys[3..],
        key,
      ].compact.join("_")
    else
      key
    end
  end

private

  def compact_nested(object)
    return object unless object.respond_to?(:compact_blank!)

    object.compact_blank!
    object.each { |o| compact_nested(o) }
    object
  end
end
