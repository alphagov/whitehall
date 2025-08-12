class ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent < ViewComponent::Base
  include ErrorsHelper
  include ContentBlockManager::ContentBlock::TranslationHelper

  PARENT_CLASS = "content_block_manager_content_block_edition".freeze

  def initialize(content_block_edition:, field:, value: nil, subschema: nil, **_args)
    @content_block_edition = content_block_edition
    @field = field
    @value = value || field.default_value
    @subschema = subschema
  end

private

  attr_reader :content_block_edition, :field, :subschema, :value

  def subschema_block_type
    @subschema_block_type ||= subschema&.block_type
  end

  def label
    optional = field.is_required? ? nil : optional_label
    "#{humanized_label(relative_key: field.name, root_object: subschema_block_type)}" \
    "#{optional}"
  end

  def optional_label
    " (optional)"
  end

  def name
    if subschema_block_type
      "content_block/edition[details][#{subschema_block_type}][#{field.name}]"
    else
      "content_block/edition[details][#{field.name}]"
    end
  end

  def id
    "#{PARENT_CLASS}_details_#{id_suffix}"
  end

  def error_items
    errors_for(content_block_edition.errors, "details_#{id_suffix}".to_sym)
  end

  def hint
    I18n.t("content_block_edition.details.hints.#{translation_lookup}", default: nil)
  end

  def translation_lookup
    @translation_lookup ||= subschema_block_type ? "#{subschema_block_type}.#{field.name}" : field.name
  end

  def id_suffix
    subschema_block_type ? "#{subschema_block_type}_#{field.name}" : field.name
  end
end
