class ContentObjectStore::ContentBlockEdition::New::ErrorSummaryComponent < ViewComponent::Base
  def initialize(error_message:)
    @error_message = error_message
  end

private

  attr_reader :error_message
end
