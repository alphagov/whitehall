module SyncChecker::Formats
  class ConsultationCheck < EditionBase
    def expected_details_hash(consultation)
      super.tap do |details|
        details.except!(:change_history) unless consultation.change_history.present?
        details.merge!(expected_documents(consultation))
        details.merge!(expected_external_url(consultation))
        details.merge!(expected_final_outcome(consultation))
        details.merge!(expected_national_applicability(consultation))
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

    def expected_documents(consultation)
      return {} unless consultation.attachments.present?

      {
        documents: Whitehall::GovspeakRenderer.new.block_attachments(
          consultation.attachments,
          consultation.alternative_format_contact_email
        )
      }
    end

    def expected_external_url(consultation)
      return {} unless consultation.external?

      { held_on_another_website_url: consultation.external_url }
    end

    def expected_final_outcome(consultation)
      return {} unless consultation.outcome_published?

      outcome = consultation.outcome

      {
        final_outcome_detail: outcome.summary,
        final_outcome_documents: if outcome.attachments.present?
                                   Whitehall::GovspeakRenderer
                                     .new
                                     .block_attachments(
                                       outcome.attachments,
                                       outcome.alternative_format_contact_email,
                                     )
                                 end,
      }.compact
    end

    def expected_national_applicability(consultation)
      return {} unless consultation.nation_inapplicabilities.present?

      {
        national_applicability: consultation.national_applicability.deep_stringify_keys
      }
    end

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
