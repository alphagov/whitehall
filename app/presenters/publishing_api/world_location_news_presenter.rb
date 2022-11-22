module PublishingApi
  class WorldLocationNewsPresenter
    include FeaturedDocumentsPresenter

    attr_accessor :world_location, :world_location_news, :update_type

    def initialize(world_location_news, update_type: nil)
      self.world_location_news = world_location_news
      self.world_location = world_location_news.world_location
      self.update_type = update_type || "major"
    end

    def content_id
      if world_location.world_location?
        world_location_news.content_id
      elsif world_location.international_delegation?
        world_location.content_id
      end
    end

    def content
      content = BaseItemPresenter.new(
        world_location_news,
        title: world_location_news.title,
        update_type:,
      ).base_attributes

      content.merge!(
        description: I18n.t("world_news.uk_updates_in_country", country: world_location.name),
        details: {
          ordered_featured_links: featured_links,
          mission_statement: world_location_news.mission_statement || "",
          ordered_featured_documents: featured_documents(world_location_news, WorldLocationNews::FEATURED_DOCUMENTS_DISPLAY_LIMIT),
          world_location_news_type: world_location.world_location_type,
        },
        document_type: "world_location_news",
        public_updated_at: world_location_news.updated_at,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name: "world_location_news",
        base_path: path_for_news_page,
      )
      content.merge!(PayloadBuilder::Routes.for(path_for_news_page))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(world_location))
    end

    def links
      {
        ordered_contacts: world_location_news.contacts.map(&:content_id),
        organisations: world_location_news.organisations.map(&:content_id),
        worldwide_organisations: world_location_news.worldwide_organisations.map(&:content_id),
      }
    end

  private

    def featured_links
      world_location_news.featured_links.limit(FeaturedLink::DEFAULT_SET_SIZE).map do |link|
        {
          title: link.title,
          href: link.url,
        }
      end
    end

    def path_for_news_page
      if world_location.world_location?
        Whitehall.url_maker.world_location_news_index_path(world_location)
      elsif world_location.international_delegation?
        Whitehall.url_maker.world_location_path(world_location)
      end
    end
  end
end
