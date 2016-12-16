module SyncChecker::Formats
  class ConsultationCheck < EditionBase
    def expected_details_hash(consultation)
      super.tap do |details|
        details.except!(:change_history) unless consultation.change_history.present?
      end
    end

    def rendering_app
      Whitehall::RenderingApp::WHITEHALL_FRONTEND
    end

    def root_path
      '/government/consultations/'
    end
  end
end
