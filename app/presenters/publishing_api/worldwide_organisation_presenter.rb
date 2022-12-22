module PublishingApi
  class WorldwideOrganisationPresenter
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
        description:,
        details: {
          social_media_links:,
        },
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "worldwide_organisation",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {
        ordered_contacts:,
        sponsoring_organisations:,
        world_locations:,
      }
    end

    def description
      item.summary
    end

    def ordered_contacts
      return [] unless item.offices.any?

      item.offices.map(&:contact).map(&:content_id)
    end

    def social_media_links
      return [] unless item.social_media_accounts.any?

      item.social_media_accounts.map do |social_media_account|
        {
          href: social_media_account.url,
          service_type: social_media_account.service_name.parameterize,
          title: social_media_account.display_name,
        }
      end
    end

    def sponsoring_organisations
      return [] unless item.sponsoring_organisations.any?

      item.sponsoring_organisations.map(&:content_id)
    end

    def world_locations
      return [] unless item.world_locations.any?

      item.world_locations.map(&:content_id)
    end
  end
end
