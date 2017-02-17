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
            expected_statistical_data_sets(edition_expected_in_live)
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
            #file attachments won't appear in children
            #as they're not in publishing api
            filter_documents_for_locale(
              edition_expected_in_live,
              locale
            ).reject{ |attachment| attachment.is_a?(FileAttachment) }
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
        Whitehall::RenderingApp::GOVERNMENT_FRONTEND
      end

      def filter_documents_for_locale(edition, locale)
        all_attachments = edition.attachments
        #pub-api always expands the default locale so we need
        #en and '' (nil locale attachments should always be present)
        locales_to_filter = ["en", "", locale.to_s]
        locale_attachments = all_attachments.select do |attachment|
          locales_to_filter.include?(attachment.locale.to_s)
        end
        locale_attachments.map(&:content_id)
      end

      def expected_statistical_data_sets(edition)
        published_content_ids = edition.published_statistical_data_sets.pluck(:content_id)
        withdrawn_content_ids = edition.statistical_data_sets.withdrawn.pluck(:content_id)
        published_content_ids + withdrawn_content_ids
      end
    end
  end
end
