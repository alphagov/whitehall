# Note that "Policy Area" is the new name for "Topic".
class PublishingApiPresenters::PolicyAreaPlaceholder < PublishingApiPresenters::Placeholder
  def links
    extract_links([:topics])
  end

  private

  def document_type
    "policy_area"
  end
end
