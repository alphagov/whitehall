class GenericEditionPresenter
  include Presenters::PublishingApi::UpdateTypeHelper

  attr_accessor :item, :update_type

  def initialize(item, update_type: nil)
    self.item = item
    self.update_type = update_type || default_update_type(item)
  end

  delegate :content_id, to: :item

  def content
    content = PublishingApi::BaseItemPresenter.new(item, update_type:).base_attributes
    content.merge!(
      description: item.summary,
    )
  end

  def links
    PublishingApi::PayloadBuilder::Links.for(item).extract([:organisations])
  end

  def document_type
    item.display_type_key
  end
end
