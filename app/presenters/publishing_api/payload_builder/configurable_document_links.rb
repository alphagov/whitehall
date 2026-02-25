module PublishingApi::PayloadBuilder
  class ConfigurableDocumentLinks
    def self.for(item)
      builders = item.type_instance.presenter("publishing_api")["links"]
      builders.each_with_object({}) { |builder, details|
        details.merge!(send(builder, item) || {})
      }.compact
    end

    def self.parent(item)
      if item.is_child_document?
        { parent: [item.parent_edition.content_id] }
      end
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
  end
end
