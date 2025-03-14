class ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent < ViewComponent::Base
  include ErrorsHelper

  PARENT_CLASS = "content_block_manager_content_block_edition".freeze

  def initialize(content_block_edition:, field:, label: nil, value: nil, id_suffix: nil)
    @content_block_edition = content_block_edition
    @field = field
    @label = label
    @value = value
    @id_suffix = id_suffix
  end

private

  attr_reader :content_block_edition, :field

  def label
    @label || field.humanize
  end

  def value
    @value || content_block_edition.details&.fetch(field, nil)
  end

  def name
    if field.is_a?(Array)
      fields = field.map { |f| "[#{f}]" }.join
      "content_block/edition[details]#{fields}"
    else
      "content_block/edition[details][#{field}]"
    end
  end

  def id
    "#{PARENT_CLASS}_details_#{@id_suffix || field}"
  end

  def error_items
    errors_for(content_block_edition.errors, "details_#{@id_suffix || field}".to_sym)
  end

  def hint
    I18n.t("content_block_edition.details.hints.#{translation_lookup}", default: nil)
  end

  def translation_lookup
    @id_suffix ? @id_suffix.gsub("_", ".") : field
  end
end
