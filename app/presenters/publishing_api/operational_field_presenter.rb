module PublishingApi
  class OperationalFieldPresenter
    attr_reader :update_type

    MINISTRY_OF_DEFENCE_CONTENT_ID = "d994e55c-48c9-4795-b872-58d8ec98af12".freeze

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
          details: {
            casualties:,
          },
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

    def casualties
      notices = operational_field.published_fatality_notices.order("first_published_at desc")
      Hash[notices.map { |notice| [notice.id, notice.fatality_notice_casualties.map(&:personal_details)] }]
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
