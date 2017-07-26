module PublishingApi
  class OperationalFieldPresenter
    attr_reader :links, :update_type

    def initialize(operational_field, **_)
      @operational_field = operational_field
      @links = {}
      @update_type = "major"
    end

    def content_id
      operational_field.content_id
    end

    def content
      {}.tap { |content|
        content.merge!(PayloadBuilder::PolymorphicPath.for(operational_field))
        content.merge!(
          description: operational_field.description,
          details: {},
          document_type: "field_of_operation",
          locale: "en",
          publishing_app: "whitehall",
          rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
          schema_name: "placeholder",
          title: operational_field.name,
          update_type: update_type,
        )
      }
    end

  private

    attr_reader :operational_field
  end
end
