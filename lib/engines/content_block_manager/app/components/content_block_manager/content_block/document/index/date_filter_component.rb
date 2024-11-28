class ContentBlockManager::ContentBlock::Document::Index::DateFilterComponent < ViewComponent::Base
  def initialize(filters: nil)
    @filters = filters
  end
end
