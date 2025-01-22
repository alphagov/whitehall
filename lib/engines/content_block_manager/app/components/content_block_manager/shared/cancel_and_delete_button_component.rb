class ContentBlockManager::Shared::CancelAndDeleteButtonComponent < ViewComponent::Base
  def initialize(url:)
    @url = url
  end

private

  attr_reader :url
end
