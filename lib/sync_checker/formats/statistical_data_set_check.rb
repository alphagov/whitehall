module SyncChecker
  module Formats
    class StatisticalDataSetCheck < EditionBase
      def root_path
        "/government/statistical-data-sets/"
      end

      def rendering_app
        Whitehall::RenderingApp::WHITEHALL_FRONTEND
      end
    end
  end
end
