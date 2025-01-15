class ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
  def initialize(content_block_edition:, field:, properties:)
    @properties = properties
    super(content_block_edition:, field:)
  end

private

  attr_reader :content_block_edition, :properties

  def items
    content_block_edition.details&.fetch(field, []) || []
  end

  def id
    "#{PARENT_CLASS}_details_#{field}"
  end

  def error_message
    error_items&.first&.fetch(:text)
  end

  def fields(object:, index:)
    properties.map { |key|
      render ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        label: key.humanize,
        field: "[#{field}][][#{key}]",
        value: object[key],
        id_suffix: "#{field}_#{index}_#{key}",
      )
    }.join("")
  end
end
