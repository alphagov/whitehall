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
            edition_expected_in_draft.related_detailed_guide_content_ids
          )
        ]
      end

      def document_type
        "detailed_guidance"
      end
    end
  end
end
