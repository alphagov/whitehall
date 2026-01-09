module ConfigurableAssociations
  class OffsiteLinks
    def initialize(association)
      @association = association
    end

    def links
      {
        offsite_links: @association.map(&:content_id),
      }
    end

    def selected_ids
      @association.ids
    end

    def options_query
      OffsiteLinks.order(:name)
    end

    def to_partial_path
      "admin/configurable_associations/topical_events"
    end
  end
end
