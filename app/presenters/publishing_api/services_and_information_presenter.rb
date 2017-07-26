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
      @content_id ||= Services.publishing_api.lookup_content_id(
        base_path: base_path
      ) || SecureRandom.uuid
    end

    def content
      content = BaseItemPresenter.new(
        organisation,
        title: "Services and information - #{organisation.name}",
        need_ids: [],
        update_type: update_type,
      ).base_attributes

      content.merge!(
        base_path: base_path,
        description: nil,
        details: {},
        document_type: "services_and_information",
        public_updated_at: organisation.updated_at,
        rendering_app: "collections",
        schema_name: "generic",
        routes: [
          {
            type: "exact",
            path: "/government/organisations/#{organisation.slug}/services-information"
          },
        ]
      )
    end

    def links
      {
        parent: [
          organisation.content_id
        ],
        organisations: [
          organisation.content_id
        ],
      }
    end

  private

    def base_path
      "/government/organisations/#{organisation.slug}/services-information"
    end
  end
end
