require_relative "../publishing_api_presenters"
require 'active_model_serializers'

class PublishingApiPresenters::CaseStudy
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
    [
      BaseItemSerializer.new(item).as_json,
      CaseStudySerializer.new(item).as_json,
      PublicDocumentPathSerializer.new(item).as_json,
      AccessLimitationSerializer.new(item).as_json,
      WithdrawnNoticeSerializer.new(item).as_json
    ].reduce(&:merge)
  end

  def links
    PublishingApiPresenters::LinksPresenter.new(item).extract(
      [
        :document_collections,
        :organisations,
        :parent,
        :related_policies,
        :topics,
        :world_locations,
        :worldwide_organisations,
      ]
    )
  end
end
