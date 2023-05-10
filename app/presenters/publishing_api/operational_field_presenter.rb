module PublishingApi
  class OperationalFieldPresenter
    attr_reader :update_type

    MINISTRY_OF_DEFENCE_CONTENT_ID = "d994e55c-48c9-4795-b872-58d8ec98af12".freeze

    def initialize(operational_field, _options = {})
      @operational_field = operational_field
      @update_type = "major"
      @renderer = Whitehall::GovspeakRenderer.new
    end

    delegate :content_id, to: :operational_field

    def content
      {}.tap do |content|
        content.merge!(PayloadBuilder::PolymorphicPath.for(operational_field))
        content.merge!(
          description: @renderer.govspeak_to_html(operational_field.description),
          details: {},
          document_type: "field_of_operation",
          locale: "en",
          publishing_app: Whitehall::PublishingApp::WHITEHALL,
          rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
          schema_name: "field_of_operation",
          title: operational_field.name,
          update_type:,
        )
      end
    end

    def links
      {
        fatality_notices: operational_field.published_fatality_notices.order("first_published_at desc").map(&:content_id),
        primary_publishing_organisation: [MINISTRY_OF_DEFENCE_CONTENT_ID],
      }
    end

  private

    attr_reader :operational_field
  end
end
