require_relative "../publishing_api_presenters"

class PublishingApiPresenters::DocumentCollectionPlaceholder < PublishingApiPresenters::Edition
  def links
    super.merge(documents: item.documents.pluck(:content_id))
  end
end
