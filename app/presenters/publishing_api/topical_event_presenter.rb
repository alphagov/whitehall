module PublishingApi
  class TopicalEventPresenter
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
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: nil,
        details: details,
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "topical_event",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      LinksPresenter.new(item).extract([:organisations])
    end

  private

    def details
      {}.tap do |details|
        details[:start_date] = item.start_date.rfc3339 if item.start_date
        details[:end_date] = item.end_date.rfc3339 if item.end_date
        details[:ordered_featured_documents] = ordered_featured_documents
      end
    end

    def ordered_featured_documents
      item.classification_featurings.includes(:image, edition: :document).map do |feature|
        {
          title: feature.title,
          href: feature.url,
          image: {
            url: feature.image.file.url(:s465),
            alt_text: feature.alt_text,
          },
          summary: feature.summary,
        }
      end
    end
  end
end
