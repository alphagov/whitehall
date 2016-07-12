require_relative "../publishing_api_presenters"

class PublishingApiPresenters::DocumentCollectionPlaceholder
  include PublishingApiPresenters::UpdateTypeHelper

  attr_accessor :item
  attr_accessor :update_type

  def initialize(item, update_type: nil)
    self.item = item
    self.update_type = update_type || default_update_type(item)
  end

  def content_id
    item.content_id
  end

  def content
    content = PublishingApiPresenters::BaseItem.new(item).base_attributes
    content.merge!(
      description: item.summary,
      details: PublishingApiPresenters::PayloadBuilder::TagDetails.for(item),
      document_type: item.display_type_key,
      public_updated_at: item.public_timestamp || item.updated_at,
      rendering_app: item.rendering_app,
      schema_name: "placeholder_#{item.class.name.underscore}",
    )
    content.merge!(PublishingApiPresenters::PayloadBuilder::PublicDocumentPath.for(item))
    content.merge!(PublishingApiPresenters::PayloadBuilder::AccessLimitation.for(item))
  end

  def links
    PublishingApiPresenters::LinksPresenter.new(item).extract(
      [:organisations, :parent, :topics]
    ).merge(documents: item.documents.pluck(:content_id))
  end
end
