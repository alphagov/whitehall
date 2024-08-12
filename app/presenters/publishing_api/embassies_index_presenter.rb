module PublishingApi
  class EmbassiesIndexPresenter
    WORLD_INDEX_CONTENT_ID = "369729ba-7776-4123-96be-2e3e98e153e1".freeze
    EMBASSIES_INDEX_CONTENT_ID = "430df081-f28e-4a1f-b812-8977fdac6e9a".freeze

    def content_id
      EMBASSIES_INDEX_CONTENT_ID
    end

    def content
      @content ||= begin
        content = BaseItemPresenter.new(
          nil,
          title:,
          update_type: "minor",
        ).base_attributes

        content.merge!(
          base_path:,
          details:,
          document_type: "embassies_index",
          rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
          schema_name: "embassies_index",
        )

        content.merge!(PayloadBuilder::Routes.for(base_path))
      end
    end

    def links
      { parent: [WORLD_INDEX_CONTENT_ID] }
    end

    def title
      I18n.t("organisation.embassies.find_an_embassy_title")
    end

    def base_path
      "/world/embassies"
    end

  private

    def details
      {
        world_locations: world_locations.map do |embassy|
          hash = {
            name: embassy.name,
            assistance_available: assistance_available(embassy),
          }
          if assistance_available(embassy) == "local"
            hash["organisations_with_embassy_offices"] = embassy.organisations_with_embassy_offices.map do |organisation|
              {
                locality: organisation.embassy_offices.first.contact.locality,
                name: organisation.name,
                path: organisation.public_path,
              }
            end
          end
          if assistance_available(embassy) == "remote"
            hash["remote_office"] = {
              name: embassy.remote_office.name,
              country: embassy.remote_office.location,
              path: embassy.remote_office.path,
            }
          end
          hash
        end,
      }
    end

    def world_locations
      WorldLocation.geographical.order(:slug)
        .includes(
          published_worldwide_organisations: [
            :document,
            :translations,
            {
              offices: [
                {
                  contact: [{ country: :translations }, :translations],
                  edition: %i[document translations],
                },
              ],
            },
          ],
        )
        .map { |location|
        # We don't want to show the UK on the embassies page.
        next if location.name.in?(["United Kingdom"])

        Embassy.new(location)
      }.reject(&:blank?)
    end

    def assistance_available(embassy)
      if embassy.can_assist_british_nationals?
        if embassy.can_assist_in_location?
          "local"
        else
          "remote"
        end
      else
        "none"
      end
    end
  end
end
