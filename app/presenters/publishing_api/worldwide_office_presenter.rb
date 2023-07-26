module PublishingApi
  class WorldwideOfficePresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.worldwide_organisation.name,
        update_type:,
      ).base_attributes

      content.merge!(
        details: {
          access_and_opening_times:,
          services:,
          type: item.worldwide_office_type.name,
        },
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "worldwide_office",
      )

      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      {
        contact:,
        parent: [item.worldwide_organisation.content_id],
        worldwide_organisation: [item.worldwide_organisation.content_id],
      }
    end

  private

    def contact
      return [] if item.contact.blank?

      [item.contact.content_id]
    end

    def access_and_opening_times
      return if item.access_and_opening_times.blank?

      Whitehall::GovspeakRenderer.new.govspeak_to_html(item.access_and_opening_times)
    end

    def services
      item.services.map do |service|
        {
          title: service.name,
          type: service.service_type.name,
        }
      end
    end
  end
end
