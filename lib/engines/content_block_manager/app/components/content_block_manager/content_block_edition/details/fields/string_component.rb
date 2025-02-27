class ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
  def initialize(content_block_edition:, field:, label: nil, value: nil, id_suffix: nil, prefix: nil)
    @prefix = prefix
    super(content_block_edition:, field:, label:, value:, id_suffix:)
  end

private

  attr_reader :prefix

  def value
    @value || content_block_edition.details&.fetch(
      field,
      prefix,
    )
  end

  def data
    if prefix
      { "prefix" => prefix, "module" => "form-prefix" }
    else
      {}
    end
  end
end
