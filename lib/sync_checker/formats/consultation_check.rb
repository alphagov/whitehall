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

  private

    LENGTH_OF_FRACTIONAL_SECONDS = 3

    def first_public_at(consultation)
      (consultation.first_published_at || consultation.document.created_at)
        .to_datetime
        .rfc3339(LENGTH_OF_FRACTIONAL_SECONDS)
    end

    def top_level_fields_hash(consultation, _)
      super.tap do |fields|
        fields[:document_type] = consultation.display_type_key
      end
    end
  end
end
