class ContentBlockManager::ContentBlock::Document::Index::FilterOptionsComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper
  def initialize(filters:)
    @filters = filters
  end

private

  def items_for_block_type
    ContentBlockManager::ContentBlock::Schema.valid_schemas.map do |schema_name|
      {
        label: schema_name.humanize,
        value: schema_name,
        checked: !@filters.nil? && @filters[:block_type]&.include?(schema_name),
      }
    end
  end
end
