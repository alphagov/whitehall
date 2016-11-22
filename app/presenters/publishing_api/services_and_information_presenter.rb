module PublishingApi
  class ServicesAndInformationPresenter
    include ApplicationHelper

    attr_accessor :organisation

    def initialize(organisation)
      self.organisation = organisation
    end

    # Updates are always classed as "minor" because we don't actually
    # have any content in the content item, only metadata.
    def update_type
      "minor"
    end

    def content_id
      @content_id ||= Whitehall.publishing_api_v2_client.lookup_content_id(
        base_path: base_path
      ) || SecureRandom.uuid
    end

    def content
      # We're not using the BaseItemPresenter here since it's a special_route
      # and the BaseItemPresenter adds extra fields that are not allowed by
      # that schema.
      {
        base_path: base_path,
        title: "Services and information - #{organisation.name}",
        description: "",
        document_type: "special_route",
        public_updated_at: organisation.updated_at,
        publishing_app: "whitehall",
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "special_route",
        routes: [
          {
            type: "exact",
            path: "/government/organisations/#{organisation.slug}/services-information"
          },
        ]
      }
    end

    def links
      {
        parent: [
          organisation.content_id
        ]
      }
    end

  private

    def base_path
      "/government/organisations/#{organisation.slug}/services-information"
    end
  end
end
