# Legacy
module ConfigurableAssociations
  class TopicalEventDocuments
    def initialize(association)
      @association = association
    end

    def selected_ids
      @association.ids
    end

    def options_query
      StandardEdition
        .latest_edition
        .where(configurable_document_type: "topical_event")
        .order(:title)
    end

    def to_partial_path
      "admin/configurable_associations/topical_event_documents"
    end
  end
end
