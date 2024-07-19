module PublishingApi
  class WorldwideCorporateInformationPagePresenter
    include Presenters::PublishingApi::UpdateTypeHelper

    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type =
        update_type || default_update_type(item)
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(
        item,
        update_type:,
      ).base_attributes

      content.merge!(PayloadBuilder::CorporateInformationPage.for(item))
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))

      content.merge!(
        document_type:,
        schema_name: "worldwide_corporate_information_page",
        links: {
          parent: [item.worldwide_organisation.content_id],
          worldwide_organisation: [item.worldwide_organisation.content_id],
        },
      )
    end

    def links
      {}
    end

    def document_type
      item.display_type_key
    end
  end
end
