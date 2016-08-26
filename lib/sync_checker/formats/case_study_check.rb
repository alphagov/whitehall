module SyncChecker
  module Formats
    class CaseStudyCheck < EditionBase
      def root_path
        "/government/case-studies/"
      end

      def rendering_app
        Whitehall::RenderingApp::GOVERNMENT_FRONTEND
      end
    end
  end
end
