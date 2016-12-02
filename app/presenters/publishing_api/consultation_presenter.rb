module PublishingApi
  class ConsultationPresenter
    extend Forwardable

    SCHEMA_NAME = 'consultation'

    def initialize(consultation)
      self.consultation = consultation
    end

    def content
      BaseItemPresenter
        .new(consultation)
        .base_attributes
        .merge(PayloadBuilder::PublicDocumentPath.for(consultation))
        .merge(
          description: consultation.summary,
          details: details,
          document_type: document_type,
          public_updated_at: public_updated_at,
          rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
          schema_name: SCHEMA_NAME,
        )
    end

  private

    attr_accessor :consultation
    def_delegator :consultation, :display_type_key, :document_type

    def base_details
      {
        body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(consultation),
      }
    end

    def details
      base_details
        .merge(PayloadBuilder::PoliticalDetails.for(consultation))
    end

    def public_updated_at
      public_updated_at = (consultation.public_timestamp || consultation.updated_at)
      public_updated_at = if public_updated_at.respond_to?(:to_datetime)
                            public_updated_at.to_datetime
                          end

      public_updated_at.rfc3339
    end
  end
end
