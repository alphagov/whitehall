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
          details: details,
          document_type: document_type,
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
  end
end
