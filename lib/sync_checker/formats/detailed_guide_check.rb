module SyncChecker
  module Formats
    class DetailedGuideCheck < EditionBase
      def root_path
        "/guidance/"
      end

      def checks_for_live(locale)
        super + [
          Checks::LinksCheck.new(
            "related_guides",
            edition_expected_in_live
              .published_related_detailed_guides
              .reject(&:unpublishing)
              .map(&:content_id)
              .uniq
          ),
          Checks::LinksCheck.new(
            "related_mainstream_content",
            related_mainstream_content_ids(edition_expected_in_live)
          ),
          Checks::LinksCheck.new(
            "document_collections",
            edition_expected_in_live
              .document_collections
              .published
              .map(&:content_id)
          )
        ]
      end

      def document_type(_edition)
        "detailed_guide"
      end

      def expected_details_hash(edition)
        super.tap do |expected_details_hash|
          expected_details_hash.merge(
            national_applicability: edition.national_applicability
          ) if edition.nation_inapplicabilities.any?

          expected_details_hash.merge(
            related_mainstream_content: related_mainstream_content_ids(edition)
          )
        end
      end

    private

      def related_mainstream_content_ids(edition)
        edition.related_mainstreams.pluck(:content_id)
      end

      def rendering_app
        Whitehall::RenderingApp::GOVERNMENT_FRONTEND
      end
    end
  end
end
