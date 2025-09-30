module PublishingApi
  class StandardEditionPresenter
    include Presenters::PublishingApi::UpdateTypeHelper
    include Presenters::PublishingApi::PayloadHeadingsHelper

    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || default_update_type(item)
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(item, update_type:).base_attributes
      content.merge!(
        description: item.summary,
        details:,
        document_type: item.class.config.publishing_api_document_type,
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: item.class.config.rendering_app,
        schema_name: item.class.config.publishing_api_schema_name,
        links:,
        auth_bypass_ids: [item.auth_bypass_id],
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def links
      item.class.configurable_associations.reduce({}) do |links_hash, association_klass|
        links_hash.merge(association_klass.new(item).links)
      end
    end

  private

    def details
      details = item.block_content.as_json
      details.merge!(extract_headings_from_model(item.block_content))
      details.merge!(PayloadBuilder::ChangeHistory.for(item))
      details.merge!(PayloadBuilder::PoliticalDetails.for(item)) if item.can_be_marked_political?
      details.merge!(PayloadBuilder::Attachments.for(item)) if item.respond_to?(:attachments)
      details
    end
  end
end
