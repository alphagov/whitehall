module SyncChecker::Formats
  class ConsultationCheck < EditionBase
    def expected_details_hash(consultation)
      super.tap do |details|
        details.except!(:change_history) unless consultation.change_history.present?
        details.merge!(expected_documents(consultation))
        details.merge!(expected_external_url(consultation))
        details.merge!(expected_final_outcome(consultation))
        details.merge!(expected_national_applicability(consultation))
        details.merge!(expected_public_feedback(consultation))
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
        documents: govspeak_renderer.block_attachments(
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
                                   govspeak_renderer
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

    def expected_public_feedback(consultation)
      public_feedback = consultation.public_feedback

      return {} unless consultation.closed? && public_feedback.present?

      detail = if public_feedback.summary.present?
                 govspeak_renderer.govspeak_to_html(public_feedback.summary)
               end

      documents = if public_feedback.attachments.present?
                    govspeak_renderer
                      .block_attachments(
                        public_feedback.attachments,
                        public_feedback.alternative_format_contact_email,
                      )
                  end

      publication_date = public_feedback.published_on.try(:rfc3339)

      {
        public_feedback_detail: detail,
        public_feedback_documents: documents,
        public_feedback_publication_date: publication_date,
      }.compact
    end

    def first_public_at(consultation)
      (consultation.first_published_at || consultation.document.created_at)
        .to_datetime
        .rfc3339(LENGTH_OF_FRACTIONAL_SECONDS)
    end

    def govspeak_renderer
      @govspeak_renderer ||= Whitehall::GovspeakRenderer.new
    end

    def top_level_fields_hash(consultation, _)
      super.tap do |fields|
        fields[:document_type] = consultation.display_type_key
      end
    end
  end
end
