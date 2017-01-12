module SyncChecker
  module Formats
    class HtmlAttachmentCheck
      def self.scope
        HtmlAttachment.where(
          attachable_id: Edition.where(state: %w(draft published withdrawn)).pluck(:id))
      end

      def self.scope_with_ids(ids)
        HtmlAttachment.where(id: ids)
      end

      def self.republish(id)
        document_id = Edition.where(id: HtmlAttachment.where(id: id).pluck(:attachable_id)).pluck(:document_id)
        if document_id.any?
          PublishingApiDocumentRepublishingWorker.new.perform(document_id.first)
        end
      end

      def initialize(attachment)
        @attachment = attachment
        @locale = (attachment.locale || "en").to_str
      end

      def checks_for_draft
        if attachment_should_exist_in_draft_content_store?
          [
            Checks::TopLevelCheck.new(
              top_level_fields_hash
            ),
            Checks::DetailsCheck.new(
              expected_details_hash
            )
          ]
        else
          []
        end
      end

      def check_draft(response, locale)
        run_checks(response, locale, checks_for_draft, DRAFT_CONTENT_STORE)
      end

      def checks_for_live
        if attachment_should_exist_in_live_content_store?
          [
            Checks::TopLevelCheck.new(
              top_level_fields_hash
            ),
            Checks::LinksCheck.new(
              "organisations",
              (attachable.try(:organisations) || []).map(&:content_id)
            ),
            Checks::LinksCheck.new(
              "parent",
              [attachable.content_id]
            ),
            Checks::DetailsCheck.new(
              expected_details_hash
            ),
            Checks::HtmlAttachmentUnpublishedCheck.new(
              attachment
            )
          ]
        else
          []
        end
      end

      def check_live(response, locale)
        run_checks(response, locale, checks_for_live, LIVE_CONTENT_STORE)
      end

      def base_paths
        {
          draft: { locale => attachment.url },
          live: { locale => attachment.url }
        }
      end

    private

      attr_reader :attachment, :locale

      def attachable
        attachment.attachable
      end

      def expected_details_hash
        {
          body: attachment.govspeak_content_body_html
        }
      end

      def top_level_fields_hash
        {
          base_path: attachment.url,
          content_id: attachment.content_id,
          document_type: "html_publication",
          locale: locale,
          publishing_app: "whitehall",
          schema_name: "html_publication",
          title: attachment.title,
          description: nil,
          rendering_app: rendering_app
        }
      end

      def attachment_should_exist_in_live_content_store?
        !attachment.deleted? && (
          Edition::PUBLICLY_VISIBLE_STATES.include?(attachable.state) ||
            attachable_is_unpublished?
        )
      end

      def attachment_should_exist_in_draft_content_store?
        !attachment.deleted? && (
          attachable_is_the_latest_draft? || attachable_is_published_and_there_is_no_newer_draft?
        )
      end

      def attachable_is_the_latest_draft?
        attachable == document.pre_publication_edition
      end

      def attachable_is_published_and_there_is_no_newer_draft?
        attachable == document.published_edition &&
          document.pre_publication_edition.nil?
      end

      def attachable_is_unpublished?
        attachable.draft? && attachable.unpublishing
      end

      def document
        @document ||= attachable.document
      end

      def rendering_app
        Whitehall::RenderingApp::GOVERNMENT_FRONTEND
      end

      def run_checks(response, locale, checks, content_store)
        errors = checks.flat_map { |check| check.call(response) }

        if errors.any?
          return Failure.new(
            response.request.base_url,
            response.response_code,
            attachable.id,
            attachment.id,
            locale,
            content_store,
            errors
          )
        end
      end
    end
  end
end
