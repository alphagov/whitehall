module PublishingApi
  class CallForEvidencePresenter
    include Presenters::PublishingApi::UpdateTypeHelper

    SCHEMA_NAME = "call_for_evidence".freeze

    attr_reader :update_type

    delegate :content_id, to: :call_for_evidence

    def initialize(call_for_evidence, update_type: nil)
      self.call_for_evidence = call_for_evidence
      self.update_type = update_type || default_update_type(call_for_evidence)
    end

    def content
      BaseItemPresenter
        .new(call_for_evidence, update_type:)
        .base_attributes
        .merge(PayloadBuilder::AccessLimitation.for(call_for_evidence))
        .merge(PayloadBuilder::PublicDocumentPath.for(call_for_evidence))
        .merge(
          description: call_for_evidence.summary,
          details:,
          document_type:,
          public_updated_at:,
          rendering_app: Whitehall::RenderingApp::FRONTEND,
          schema_name: SCHEMA_NAME,
          links: edition_links,
          auth_bypass_ids: [call_for_evidence.auth_bypass_id],
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
      PayloadBuilder::Links
        .for(call_for_evidence)
        .extract(%i[organisations government])
        .merge(PayloadBuilder::People.for(call_for_evidence))
        .merge(PayloadBuilder::Roles.for(call_for_evidence))
        .merge(PayloadBuilder::TopicalEvents.for(call_for_evidence))
    end

  private

    attr_accessor :call_for_evidence
    attr_writer :update_type

    delegate :display_type_key, to: :call_for_evidence
    alias_method :document_type, :display_type_key

    def base_details
      {
        body:,
        closing_date: call_for_evidence.closing_at,
        emphasised_organisations: call_for_evidence.lead_organisations.map(&:content_id),
        opening_date: call_for_evidence.opening_at,
      }
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(call_for_evidence)
    end

    def details
      base_details
        .merge(PayloadBuilder::ChangeHistory.for(call_for_evidence))
        .merge(PayloadBuilder::Documents.for(call_for_evidence))
        .merge(PayloadBuilder::ExternalUrl.for(call_for_evidence))
        .merge(Outcome.for(call_for_evidence))
        .merge(PayloadBuilder::NationalApplicability.for(call_for_evidence))
        .merge(WaysToRespond.for(call_for_evidence))
        .merge(PayloadBuilder::FirstPublicAt.for(call_for_evidence))
        .merge(PayloadBuilder::PoliticalDetails.for(call_for_evidence))
        .merge(PayloadBuilder::TagDetails.for(call_for_evidence))
        .merge(PayloadBuilder::Attachments.for([call_for_evidence, call_for_evidence.outcome]))
    end

    def public_updated_at
      public_updated_at = call_for_evidence.public_timestamp || call_for_evidence.updated_at
      public_updated_at.rfc3339
    end

    class Outcome
      def self.for(call_for_evidence)
        new(call_for_evidence).call
      end

      def initialize(call_for_evidence, renderer: Whitehall::GovspeakRenderer.new)
        self.call_for_evidence = call_for_evidence
        self.renderer = renderer
      end

      def call
        return {} unless call_for_evidence.outcome_published?

        {
          outcome_detail:,
          outcome_documents:,
          outcome_attachments:,
        }.compact
      end

    private

      attr_accessor :call_for_evidence, :renderer

      delegate :outcome, to: :call_for_evidence

      def outcome_detail
        renderer.govspeak_to_html(outcome.summary)
      end

      def outcome_documents
        return if outcome.attachments.blank?

        renderer.block_attachments(
          outcome.attachments,
          outcome.alternative_format_contact_email,
        )
      end

      def outcome_attachments
        outcome.attachments_ready_for_publishing.map { |a| a.publishing_api_details[:id] }
      end
    end

    class WaysToRespond
      def self.for(call_for_evidence)
        new(call_for_evidence).call
      end

      def initialize(call_for_evidence)
        self.call_for_evidence = call_for_evidence
      end

      def call
        return {} if call_for_evidence.external? ||
          !call_for_evidence.open? ||
          !call_for_evidence.has_call_for_evidence_participation?

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

      attr_accessor :call_for_evidence

      delegate :call_for_evidence_participation, to: :call_for_evidence
      delegate :call_for_evidence_response_form, to: :participation
      alias_method :participation, :call_for_evidence_participation
      alias_method :participation_response_form, :call_for_evidence_response_form

      def attachment_url
        return unless participation.has_response_form? && participation.call_for_evidence_response_form_uploaded_to_asset_manager?

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
