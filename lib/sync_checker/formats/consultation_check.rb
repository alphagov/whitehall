module SyncChecker::Formats
  class ConsultationCheck < EditionBase
    def rendering_app
      Whitehall::RenderingApp::WHITEHALL_FRONTEND
    end

    def root_path
      '/government/consultations/'
    end
  end
end
