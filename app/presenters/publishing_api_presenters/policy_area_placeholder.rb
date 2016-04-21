# Note that "Policy Area" is the new name for "Topic".
class PublishingApiPresenters::PolicyAreaPlaceholder < PublishingApiPresenters::Placeholder
  def links
    extract_links([:topics, :organisations])
  end

  private

  def document_format
    "placeholder_policy_area"
  end
end
