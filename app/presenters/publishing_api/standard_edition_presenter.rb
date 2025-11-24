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
        document_type: type.settings["publishing_api_document_type"],
        public_updated_at: (item.public_timestamp || item.updated_at).rfc3339,
        rendering_app: type.settings["rendering_app"],
        schema_name: type.settings["publishing_api_schema_name"],
        links:,
        auth_bypass_ids: [item.auth_bypass_id],
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def links
      PayloadBuilder::ConfigurableDocumentLinks.for(item)
    end

    def document_type
      type.settings["publishing_api_document_type"]
    end

  private

    def details
      root_block = ConfigurableContentBlocks::Factory.new(item).build("object")
      details = {
        **root_block.publishing_api_payload(type.schema, item.block_content),
      }
      details.merge!(PayloadBuilder::ChangeHistory.for(item)) if type.settings["send_change_history"] == true
      details.merge!(PayloadBuilder::PoliticalDetails.for(item)) if type.settings["history_mode_enabled"] == true
      details.merge!(PayloadBuilder::Attachments.for(item)) if type.settings["file_attachments_enabled"] == true
      details.merge!(PayloadBuilder::EmphasisedOrganisations.for(item)) if item.organisation_association_enabled?
      details.merge!({ headers: }.compact) if type.schema.key? "headings_from"
      details
    end

    def headers
      headings = type.schema["headings_from"].map do |block_attribute|
        extract_headings(item.block_content.public_send(block_attribute))[:headers]
      end
      headings.any? ? headings.flatten : nil
    end

    def type
      item.type_instance
    end
  end
end
