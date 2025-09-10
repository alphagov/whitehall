module PublishingApi
  class PersonPresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.name,
        update_type:,
      ).base_attributes

      content.merge!(
        description: item.biography_without_markup,
        details:,
        document_type: "person",
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name: "person",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      {
        organisations: [],
      }
    end

    def details
      details_hash = {}

      if item.image&.asset_uploaded? && item.image.url(:s465)
        logger.error("PersonPresenter: Person of ID##{item.id} has image with url '#{item.image&.url(:s465)}'") if item.image.url(:s465).include?("carrierwave-tmp")
        details_hash[:image] = { url: item.image.url(:s465), alt_text: item.name }
      end

      details_hash.merge(
        full_name: item.full_name,
        privy_counsellor: item.privy_counsellor?,
        body:,
      )
    end

    def body
      [
        {
          content_type: "text/govspeak",
          content: item.biography || "",
        },
      ]
    end
  end
end
