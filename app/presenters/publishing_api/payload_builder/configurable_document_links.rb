module PublishingApi::PayloadBuilder
  class ConfigurableDocumentLinks
    def self.for(item)
      builders = item.type_instance.presenter("publishing_api")["links"]
      builders.each_with_object({}) { |builder, details|
        details.merge!(send(builder, item))
      }.compact
    end

    def self.ministerial_role_appointments(item)
      links = { people: Set.new, roles: Set.new }
      item.role_appointments.includes(:person, :role).each_with_object(links) do |appointment, result|
        result[:people] << appointment.person.content_id
        result[:roles] << appointment.role.content_id
      end
      links.transform_values(&:to_a)
    end

    def self.topical_events(item)
      topical_events = item.topical_events.map(&:content_id) + item.topical_event_documents.map(&:content_id)
      { topical_events: }
    end

    def self.world_locations(item)
      { world_locations: item.world_locations.map(&:content_id) }
    end

    def self.organisations(item)
      sorted_organisations = item.edition_organisations.sort_by do |edition_org|
        [edition_org.lead_ordering ? 0 : 1, edition_org.lead_ordering]
      end

      emphasised_organisations = sorted_organisations
        .filter(&:lead?)
        .map { |edition_org| edition_org.organisation.content_id }

      primary_publishing_organisation = item.edition_organisations.select(&:lead?)
          .min_by(&:lead_ordering)
          &.organisation&.content_id

      {
        organisations: sorted_organisations.map { |edition_org| edition_org.organisation.content_id },
        primary_publishing_organisation: [primary_publishing_organisation].compact,
        emphasised_organisations:,
      }
    end

    def self.worldwide_organisations(item)
      { worldwide_organisations: item.worldwide_organisation_documents.map(&:content_id) }
    end

    def self.government(item)
      { government: [item.government&.content_id].compact }
    end

    def self.linked_navigation_documents(item)
      content = item.block_content["linked_navigation_documents"]
      return nil if content.nil?

      # TODO: simplify. This originally was going to be an array of objects but is now just a list of content IDs
      # e.g.
      # [
      #   "05c902c3-8272-4940-be0c-2c71e36e538d"
      # ]
      # All we're doing is parsing the JSON above, but we could probably make this
      # a comma separated list, or even better, use the array / add-another component
      { documents: JSON.parse(content) }
    end
  end
end
