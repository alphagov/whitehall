class ContentBlockManager::ContentBlock::Document::Index::DateFilterComponent < ViewComponent::Base
  def initialize(filters: nil)
    @filters = filters
  end

private

  attr_reader :filters

  def date_value(date, date_part)
    filters&.dig(date, date_part)
  end
end
