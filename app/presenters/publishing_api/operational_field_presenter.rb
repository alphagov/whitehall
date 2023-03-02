module PublishingApi
  class OperationalFieldPresenter
    attr_reader :update_type

    def initialize(operational_field, _options = {})
      @operational_field = operational_field
      @update_type = "major"
    end

    delegate :content_id, to: :operational_field

    def content
      {}.tap do |content|
        content.merge!(PayloadBuilder::PolymorphicPath.for(operational_field))
        content.merge!(
          description: operational_field.description,
          details: {},
          document_type: "field_of_operation",
          locale: "en",
          publishing_app: "whitehall",
          rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
          schema_name: "field_of_operation",
          title: operational_field.name,
          update_type:,
        )
      end
    end

    def links
      {
        fatality_notices: operational_field.published_fatality_notices.order("first_published_at desc").map(&:content_id),
      }
    end

  private

    attr_reader :operational_field
  end
end
