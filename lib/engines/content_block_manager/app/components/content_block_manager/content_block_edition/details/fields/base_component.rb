class ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent < ViewComponent::Base
  include ErrorsHelper

  PARENT_CLASS = "content_block_manager_content_block_edition".freeze

  def initialize(content_block_edition:, field:, value: nil, object_id: nil)
    @content_block_edition = content_block_edition
    @field = field
    @value = value || content_block_edition.details&.fetch(field.name, nil)
    @object_id = object_id
  end

private

  attr_reader :content_block_edition, :field, :object_id, :value

  def label
    field.name.humanize
  end

  def name
    if object_id
      "content_block/edition[details][#{object_id}][#{field.name}]"
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
    @translation_lookup ||= object_id ? "#{object_id}.#{field.name}" : field.name
  end

  def id_suffix
    object_id ? "#{object_id}_#{field.name}" : field.name
  end
end
