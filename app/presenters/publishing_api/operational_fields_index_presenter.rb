module PublishingApi
  class OperationalFieldsIndexPresenter
    attr_accessor :update_type

    def initialize(update_type: nil)
      self.update_type = update_type || "major"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "Fields of operation",
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        details: {},
        document_type: "fields_of_operation",
        public_updated_at: Time.zone.now,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "fields_of_operation",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def links
      { fields_of_operation: OperationalField.all.map(&:content_id) }
    end

    def content_id
      "53c8e227-3778-4c85-a569-384457c0a281"
    end

    def base_path
      "/government/fields-of-operation"
    end
  end
end
