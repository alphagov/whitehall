module PublishingApi
  class ConsultationPresenter
    include UpdateTypeHelper

    SCHEMA_NAME = "consultation".freeze

    attr_reader :update_type

    delegate :content_id, to: :consultation

    def initialize(consultation, update_type: nil)
      self.consultation = consultation
      self.update_type = update_type || default_update_type(consultation)
    end

    def content
      BaseItemPresenter
        .new(consultation, update_type:)
        .base_attributes
        .merge(PayloadBuilder::AccessLimitation.for(consultation))
        .merge(PayloadBuilder::PublicDocumentPath.for(consultation))
        .merge(
          description: consultation.summary,
          details:,
          document_type:,
          public_updated_at:,
          rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
          schema_name: SCHEMA_NAME,
          links: edition_links,
          auth_bypass_ids: [consultation.auth_bypass_id],
        )
    end

    def links
      # TODO: Previously, this presenter was sending all links to the
      # Publishing API at both the document level, and edition
      # level. This is probably redundant, and hopefully can be
      # improved.
      edition_links
    end

    def edition_links
      LinksPresenter
        .new(consultation)
        .extract(%i[organisations parent topics government])
        .merge(PayloadBuilder::People.for(consultation))
        .merge(PayloadBuilder::Roles.for(consultation))
        .merge(PayloadBuilder::TopicalEvents.for(consultation))
    end

  private

    attr_accessor :consultation
    attr_writer :update_type

    delegate :display_type_key, to: :consultation
    alias_method :document_type, :display_type_key

    def base_details
      {
        body:,
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
        .merge(PayloadBuilder::Attachments.for([consultation, consultation.outcome, consultation.public_feedback]))
    end

    def public_updated_at
      public_updated_at = (consultation.public_timestamp || consultation.updated_at)
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
        return {} if consultation.change_history.blank?

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
        return {} if consultation.attachments.blank?

        {
          documents:,
          featured_attachments:,
        }
      end

    private

      attr_accessor :consultation, :renderer

      def documents
        renderer.block_attachments(
          consultation.attachments,
          consultation.alternative_format_contact_email,
        )
      end

      def featured_attachments
        consultation.attachments.map { |a| a.publishing_api_details[:id] }
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
          final_outcome_detail:,
          final_outcome_documents:,
          final_outcome_attachments:,
        }.compact
      end

    private

      attr_accessor :consultation, :renderer

      delegate :outcome, to: :consultation

      def final_outcome_detail
        renderer.govspeak_to_html(outcome.summary)
      end

      def final_outcome_documents
        return if outcome.attachments.blank?

        renderer.block_attachments(
          outcome.attachments,
          outcome.alternative_format_contact_email,
        )
      end

      def final_outcome_attachments
        outcome.attachments.map { |a| a.publishing_api_details[:id] }
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
        return {} if consultation.nation_inapplicabilities.blank?

        { national_applicability: consultation.national_applicability }
      end

    private

      attr_accessor :consultation
    end

    class PublicFeedback
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
          public_feedback_attachments: attachments,
          public_feedback_publication_date: publication_date,
        }.compact
      end

    private

      attr_accessor :consultation, :renderer

      delegate :public_feedback, to: :consultation

      def detail
        return if public_feedback.summary.blank?

        renderer.govspeak_to_html(public_feedback.summary)
      end

      def documents
        return if public_feedback.attachments.blank?

        renderer.block_attachments(
          public_feedback.attachments,
          public_feedback.alternative_format_contact_email,
          public_feedback.published_on,
        )
      end

      def attachments
        public_feedback.attachments.map { |a| a.publishing_api_details[:id] }
      end

      def publication_date
        return if public_feedback.published_on.blank?

        public_feedback.published_on.rfc3339
      end
    end

    class WaysToRespond
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
            email:,
            link_url:,
            postal_address:,
            attachment_url:,
          }.compact,
        }.compact
      end

    private

      attr_accessor :consultation, :url_helpers

      delegate :consultation_participation, to: :consultation
      delegate :consultation_response_form, to: :participation
      alias_method :participation, :consultation_participation
      alias_method :participation_response_form, :consultation_response_form

      def attachment_url
        return unless participation.has_response_form?

        participation_response_form.file.url
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
