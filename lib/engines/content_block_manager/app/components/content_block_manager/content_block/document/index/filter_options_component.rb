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

  def options_for_lead_organisation
    helpers.taggable_organisations_container.map do |name, id|
      {
        text: name,
        value: id,
        selected: !@filters.nil? && @filters[:lead_organisation] == id.to_s,
      }
    end
  end
end
