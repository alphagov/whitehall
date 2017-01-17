module SyncChecker
  module Formats
    class PublicationCheck < EditionBase
      def checks_for_live(locale)
        super + [
          Checks::LinksCheck.new(
            "document_collections",
            edition_expected_in_live
              .document_collections
              .where(state: %w(published withdrawn))
              .map(&:content_id)
          ),
          Checks::LinksCheck.new(
            "ministers",
            edition_expected_in_live
              .role_appointments
              .joins(:person)
              .pluck("people.content_id")
          ),
          Checks::LinksCheck.new(
            "related_statistical_data_sets",
            edition_expected_in_live
              .statistical_data_sets
              .where(state: %w(published withdrawn))
              .map(&:content_id)
          ),
          Checks::LinksCheck.new(
            "topical_events",
            ::TopicalEvent
              .joins(:classification_memberships)
              .where(classification_memberships: {edition_id: edition_expected_in_live.id})
              .pluck(:content_id)
          ),
          Checks::LinksCheck.new(
            "children",
            edition_expected_in_live
              .html_attachments
              .pluck(:content_id)
          )
        ]
      end

      def document_type(edition)
        edition.publication_type.key
      end

      def expected_details_hash(edition)
        super.tap do |expected_details_hash|
          expected_details_hash.merge(
            documents: Whitehall::GovspeakRenderer.new.block_attachments(edition.attachments)
          ) if edition.attachments.any?
        end
      end

    private

      def rendering_app
        Whitehall::RenderingApp::WHITEHALL_FRONTEND
      end
    end
  end
end
