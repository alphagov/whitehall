module PublishingApiPresenters
  # Note that "Policy Area" is the new name for "Topic".
  class PolicyAreaPlaceholder < Item
    def links
      extract_links([:organisations])
    end

    def title
      item.name
    end

    def description
      nil
    end

    def schema_name
      "placeholder"
    end

    def public_updated_at
      item.updated_at
    end

  private

    def document_type
      "policy_area"
    end
  end
end
