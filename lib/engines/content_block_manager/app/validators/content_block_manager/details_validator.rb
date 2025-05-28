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
    key = field_items.count > 1 ? "#{field_items.first}_#{attribute}" : attribute
    edition.errors.add(
      "details_block_attributes_#{key}",
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

private

  def compact_nested(details)
    if details.present?
      details.compact_blank.map { |k, v| v.is_a?(Hash) ? [k, compact_nested(v)] : [k, v] }.to_h
    end
  end

  def key_with_optional_prefix(error, key)
    # TODO: tidy this!
    if error["data_pointer"].present?
      if error["data_pointer"].split("/").include?("block_attributes")
        if error["data_pointer"].split("/")[2].present?
          "block_attributes_#{error['data_pointer'].split('/')[2]}_#{key}"
        else
          "block_attributes_#{key}"
        end
      else
        "#{error['data_pointer'].split('/')[1]}_#{key}"
      end
    else
      key
    end
  end
end
