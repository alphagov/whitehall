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
        .merge(PayloadBuilder::AccessLimitation.for(consultation))
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

    def links
      LinksPresenter
        .new(consultation)
        .extract(%i(organisations policy_areas topics))
    end

  private

    attr_accessor :consultation
    def_delegator :consultation, :display_type_key, :document_type

    def base_details
      {
        body: body,
        closing_date: consultation.closing_at,
        emphasised_organisations: consultation.lead_organisations.map(&:content_id),
        opening_date: consultation.opening_at,
      }
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(consultation)
    end

    def details
      base_details
        .merge(ChangeHistory.for(consultation))
        .merge(Documents.for(consultation))
        .merge(ExternalURL.for(consultation))
        .merge(FinalOutcome.for(consultation))
        .merge(NationalApplicability.for(consultation))
        .merge(PublicFeedback.for(consultation))
        .merge(WaysToRespond.for(consultation))
        .merge(PayloadBuilder::FirstPublicAt.for(consultation))
        .merge(PayloadBuilder::PoliticalDetails.for(consultation))
        .merge(PayloadBuilder::TagDetails.for(consultation))
    end

    def public_updated_at
      public_updated_at = (consultation.public_timestamp || consultation.updated_at)
      public_updated_at = if public_updated_at.respond_to?(:to_datetime)
                            public_updated_at.to_datetime
                          end

      public_updated_at.rfc3339
    end

    class ChangeHistory
      def self.for(consultation)
        new(consultation).call
      end

      def initialize(consultation)
        self.consultation = consultation
      end

      def call
        return {} unless consultation.change_history.present?

        { change_history: consultation.change_history.as_json }
      end

    private

      attr_accessor :consultation
    end

    class Documents
      def self.for(consultation)
        new(consultation).call
      end

      def initialize(consultation, renderer: Whitehall::GovspeakRenderer.new)
        self.consultation = consultation
        self.renderer = renderer
      end

      def call
        return {} unless consultation.attachments.present?

        { documents: documents }
      end

    private

      attr_accessor :consultation, :renderer

      def alternative_format_email
        consultation
          .alternative_format_provider
          .try(:alternative_format_contact_email)
      end

      def documents
        renderer.block_attachments(
          consultation.attachments,
          alternative_format_email,
        )
      end
    end

    class ExternalURL
      def self.for(consultation)
        new(consultation).call
      end

      def initialize(consultation)
        self.consultation = consultation
      end

      def call
        return {} unless consultation.external?

        { held_on_another_website_url: consultation.external_url }
      end

    private

      attr_accessor :consultation
    end

    class FinalOutcome
      extend Forwardable

      def self.for(consultation)
        new(consultation).call
      end

      def initialize(consultation, renderer: Whitehall::GovspeakRenderer.new)
        self.consultation = consultation
        self.renderer = renderer
      end

      def call
        return {} unless consultation.outcome_published?

        {
          final_outcome_detail: final_outcome_detail,
          final_outcome_documents: final_outcome_documents,
        }.compact
      end

    private

      attr_accessor :consultation, :renderer
      def_delegator :consultation, :outcome

      def alternative_format_email
        consultation
          .alternative_format_provider
          .try(:alternative_format_contact_email)
      end

      def final_outcome_detail
        outcome.summary
      end

      def final_outcome_documents
        return unless outcome.attachments.present?

        renderer.block_attachments(outcome.attachments, alternative_format_email)
      end
    end

    class NationalApplicability
      def self.for(consultation)
        new(consultation).call
      end

      def initialize(consultation)
        self.consultation = consultation
      end

      def call
        return {} unless consultation.nation_inapplicabilities.present?

        { national_applicability: consultation.national_applicability }
      end

    private

      attr_accessor :consultation
    end

    class PublicFeedback
      extend Forwardable

      def self.for(consultation)
        new(consultation).call
      end

      def initialize(consultation, renderer: Whitehall::GovspeakRenderer.new)
        self.consultation = consultation
        self.renderer = renderer
      end

      def call
        return {} unless consultation.closed? &&
            consultation.public_feedback.present?

        {
          public_feedback_detail: detail,
          public_feedback_documents: documents,
          public_feedback_publication_date: publication_date,
        }.compact
      end

    private

      attr_accessor :consultation, :renderer
      def_delegator :consultation, :public_feedback

      def detail
        return unless public_feedback.summary.present?

        renderer.govspeak_to_html(public_feedback.summary)
      end

      def documents
        return unless public_feedback.attachments.present?

        renderer.block_attachments(
          public_feedback.attachments,
          consultation.alternative_format_provider.try(:alternative_format_contact_email),
        )
      end

      def publication_date
        return unless public_feedback.published_on.present?

        public_feedback.published_on.rfc3339
      end
    end

    class WaysToRespond
      extend Forwardable

      def self.for(consultation)
        new(consultation).call
      end

      def initialize(consultation, url_helpers: Whitehall.url_maker)
        self.consultation = consultation
        self.url_helpers = url_helpers
      end

      def call
        return {} if consultation.external? ||
            !consultation.open? ||
            !consultation.has_consultation_participation?

        {
          ways_to_respond: {
            email: email,
            link_url: link_url,
            postal_address: postal_address,
            attachment_url: attachment_url,
          }.compact
        }.compact
      end

    private

      GOVERNMENT_UPLOADS_PATH = '/government/uploads/'

      attr_accessor :consultation, :url_helpers
      def_delegator :consultation, :consultation_participation, :participation
      def_delegator :participation, :consultation_response_form, :participation_response_form

      def attachment_url
        return unless participation.has_response_form?

        absolute_path = Pathname(participation_response_form.file.url)
        parent_path = Pathname(GOVERNMENT_UPLOADS_PATH)
        child_path = absolute_path.relative_path_from(parent_path)

        extension = child_path.extname
        basename = child_path.basename(extension)
        dirname = child_path.dirname

        path = File.join(dirname, basename)

        url_helpers.public_upload_url(path, extension: extension.delete('.'))
      end

      def email
        return unless participation.has_email?

        participation.email
      end

      def link_url
        return unless participation.has_link?

        participation.link_url
      end

      def postal_address
        return unless participation.has_postal_address?

        participation.postal_address
      end
    end
  end
end
