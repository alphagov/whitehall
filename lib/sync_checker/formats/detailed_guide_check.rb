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
          )
        ]
      end

      def document_type
        "detailed_guide"
      end
    end
  end
end
