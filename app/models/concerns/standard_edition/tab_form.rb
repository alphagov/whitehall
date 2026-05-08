class StandardEdition::TabForm
  include ActiveModel::Model

  attr_reader :edition, :tab_key

  validate :validate_block_content
  validate :validate_edition_fields, if: -> { edition_attribute_keys.any? }

  ADDITIONAL_DEFAULT_TAB_FIELDS = %w[title summary].freeze

  def initialize(edition, tab_key)
    @edition = edition
    @tab_key = tab_key
  end

private

  def form_config
    @form_config ||= edition.type_instance.form(tab_key).tap do |config|
      raise ArgumentError, "Unknown tab key '#{tab_key}'" unless config
    end
  end

  # Fields whose data lives inside block_content (e.g. "body", "social_media_links")
  def block_content_field_keys
    (form_config["fields"] || {}).filter_map do |_key, field|
      attr_path = Array(field["attribute_path"])
      attr_path.last if attr_path.first == "block_content"
    end
  end

  # Fields whose data lives directly on the edition (e.g. "lead_organisation_ids")
  def edition_attribute_keys
    keys = (form_config["fields"] || {}).filter_map do |_key, field|
      attr_path = Array(field["attribute_path"])
      attr_path.first unless attr_path.first == "block_content"
    end

    tab_key == edition.default_tab ? keys + ADDITIONAL_DEFAULT_TAB_FIELDS : keys # Need to move these fields into document form configuration
  end

  def scoped_block_content
    schema = edition.type_instance.schema_for_fields(block_content_field_keys)
    StandardEdition::BlockContent.new(schema).tap do |bc|
      bc.assign_attributes(edition[:block_content] || {})
    end
  end

  def validate_block_content
    block_content = scoped_block_content
    return if block_content.valid?(validation_context)

    block_content.errors.each { |error| errors.import(error, attribute: error.attribute.to_s) }
  end

  def validate_edition_fields
    edition.current_tab_context = tab_key
    edition.valid?(validation_context)
    edition.current_tab_context = nil

    edition_attribute_keys.each do |attr|
      edition.errors.where(attr.to_sym).each { |error| errors.import(error, attribute: error.attribute.to_s) }
    end
  end
end
