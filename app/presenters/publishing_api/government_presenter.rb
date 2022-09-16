module PublishingApi
  class GovernmentPresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      BaseItemPresenter.new(
        item,
        title: item.name,
        update_type:,
      ).base_attributes.merge(
        base_path:,
        details:,
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name:,
      ).merge(
        PayloadBuilder::Routes.for(base_path),
      )
    end

    def links
      {}
    end

  private

    def schema_name
      "government"
    end

    def base_path
      "/government/#{item.slug}"
    end

    def details
      {
        started_on: item.start_date.rfc3339,
        ended_on: item.end_date&.rfc3339,
        # Use ended?, rather than current?, as this just checks if the
        # Government has ended, which should be equivalent, and
        # doesn't require looking up the details of other governments
        current: !item.ended?,
      }
    end
  end
end
