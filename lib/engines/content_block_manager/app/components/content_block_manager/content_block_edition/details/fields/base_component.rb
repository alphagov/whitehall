class ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent < ViewComponent::Base
  include ErrorsHelper

  PARENT_CLASS = "content_block_manager_content_block_edition".freeze

  def initialize(content_block_edition:, field:, value: nil, parent_objects: [])
    @content_block_edition = content_block_edition
    @field = field
    @value = value
    @parent_objects = parent_objects
  end

private

  attr_reader :content_block_edition, :field, :parent_objects, :value

  def label
    field.name.humanize
  end

  def name
    "content_block/edition[details]#{field_suffix}"
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
    @translation_lookup ||= [
      *parent_objects,
      field.name,
    ].compact.join(".")
  end

  def id_suffix
    [
      *parent_objects,
      field.name,
    ].compact.join("_")
  end

  def field_suffix
    [
      *parent_objects,
      field.name,
    ].compact.map { |name|
      "[#{name}]"
    }.join
  end
end
