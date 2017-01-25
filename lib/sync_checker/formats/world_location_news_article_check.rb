module SyncChecker
  module Formats
    class WorldLocationNewsArticleCheck < EditionBase
      def root_path
        "/government/world-location-news/"
      end

      def rendering_app
        Whitehall::RenderingApp::WHITEHALL_FRONTEND
      end

      def expected_details_hash(edition)
        super.reject { |k, _| k == :emphasised_organisations }
      end

      def document_type(_edition)
        "news_article"
      end

      def checks_for_live(locale)
        super + [
          Checks::LinksCheck.new(
            "worldwide_organisations",
            edition_expected_in_live.worldwide_organisations.map(&:content_id)
          ),
          Checks::LinksCheck.new(
            "world_locations",
            edition_expected_in_live.world_locations.map(&:content_id)
          )
        ]
      end
    end
  end
end
