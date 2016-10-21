module SyncChecker
  module Formats
    class DocumentCollectionCheck < EditionBase
      def root_path
        "/government/collections/"
      end

      def rendering_app
        Whitehall::RenderingApp::WHITEHALL_FRONTEND
      end

      def checks_for_live(locale)
        super << Checks::LinksCheck.new(
          "topical_events",
          TopicalEvent
          .for_edition(edition_expected_in_live.id)
          .pluck(:content_id)
        )
      end

      def expected_details_hash(edition)
        super.merge(
          collection_groups: collection_groups(edition)
        )
      end

    private

      def top_level_fields_hash(edition, locale)
        super.merge(
          { first_published_at: edition.first_published_at }
        )
      end

      def collection_groups(edition)
        edition.groups.map do |group|
          {
            title: group.heading,
            body: govspeak_renderer.govspeak_to_html(group.body),
            documents: group.documents.collect(&:content_id)
          }.stringify_keys
        end
      end

      def govspeak_renderer
        @govspeak_renderer ||= Whitehall::GovspeakRenderer.new
      end
    end
  end
end
