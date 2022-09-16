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
        update_type:,
      ).base_attributes

      content.merge!(
        description: item.summary,
        details:,
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name: "topical_event",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item, additional_routes: %w[atom]))
    end

    def links
      LinksPresenter.new(item).extract([:organisations])
    end

  private

    def details
      {}.tap do |details|
        details[:about_page_link_text] = item.topical_event_about_page.read_more_link_text if item.topical_event_about_page && item.topical_event_about_page.read_more_link_text
        details[:body] = body
        details[:emphasised_organisations] = item.lead_organisations.map(&:content_id)
        details[:image] = image if item.logo_url
        details[:start_date] = item.start_date.rfc3339 if item.start_date
        details[:end_date] = item.end_date.rfc3339 if item.end_date
        details[:ordered_featured_documents] = ordered_featured_documents
        details[:social_media_links] = social_media_links
      end
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_to_html(item.description)
    end

    def image
      {
        url: item.logo_url(:s300),
        alt_text: item.logo_alt_text,
      }
    end

    def ordered_featured_documents
      item
        .topical_event_featurings
        .includes(:image, edition: :document)
        .limit(featured_documents_display_limit)
        .map do |feature|
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

    def social_media_links
      item.social_media_accounts.map do |social_media_account|
        {
          href: social_media_account.url,
          service_type: social_media_account.service_name.parameterize,
          title: social_media_account.display_name,
        }
      end
    end

    def featured_documents_display_limit
      item.content_id == TopicalEvent::HM_THE_QUEEN_CONTENT_ID ? 9 : FeaturedLink::DEFAULT_SET_SIZE
    end
  end
end
