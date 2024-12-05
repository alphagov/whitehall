class ContentBlockManager::ContentBlock::Document::Index::DateFilterComponent < ViewComponent::Base
  def initialize(filters: nil, errors: nil)
    @filters = filters
    @errors = errors
  end
end
