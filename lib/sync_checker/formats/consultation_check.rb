module SyncChecker::Formats
  class ConsultationCheck < EditionBase
    def expected_details_hash(consultation, _)
      super.tap do |details|
        details.except!(:change_history) unless consultation.change_history.present?
        details.merge!(expected_documents(consultation))
        details.merge!(expected_external_url(consultation))
        details.merge!(expected_final_outcome(consultation))
        details.merge!(expected_government(consultation))
        details.merge!(expected_national_applicability(consultation))
        details.merge!(expected_political(consultation))
        details.merge!(expected_public_feedback(consultation))
        details.merge!(expected_tags(consultation))
        details.merge!(expected_ways_to_respond(consultation))
      end
    end

    def rendering_app
      Whitehall::RenderingApp::GOVERNMENT_FRONTEND
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

      detail = if outcome.summary.present?
                 govspeak_renderer.govspeak_to_html(outcome.summary)
               end

      {
        final_outcome_detail: detail,
        final_outcome_documents: if outcome.attachments.present?
                                   govspeak_renderer
                                     .block_attachments(
                                       outcome.attachments,
                                       outcome.alternative_format_contact_email,
                                     )
                                 end,
      }.compact
    end

    def expected_government(consultation)
      return {} unless consultation.government

      {
        'government' => {
          'title' => consultation.government.name,
          'slug' => consultation.government.slug,
          'current' => consultation.government.current?
        }
      }
    end

    def expected_national_applicability(consultation)
      return {} unless consultation.nation_inapplicabilities.present?

      {
        national_applicability: consultation.national_applicability.deep_stringify_keys
      }
    end

    def expected_political(consultation)
      { political: consultation.political? }
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
                        public_feedback.published_on,
                      )
                  end

      publication_date = public_feedback.published_on.try(:rfc3339)

      {
        public_feedback_detail: detail,
        public_feedback_documents: documents,
        public_feedback_publication_date: publication_date,
      }.compact
    end

    def expected_tags(consultation)
      policies = if consultation.can_be_related_to_policies?
                   consultation.policies.map(&:slug)
                 end

      topics = Array(consultation.primary_specialist_sector_tag) +
        consultation.secondary_specialist_sector_tags

      {
        'tags' => {
          'browse_pages' => [],
          'policies' => policies.compact,
          'topics' => topics.compact,
        }
      }
    end

    def expected_ways_to_respond(consultation)
      return {} if consultation.external? ||
          !consultation.open? ||
          !consultation.has_consultation_participation?

      participation = consultation.consultation_participation

      attachment_url = if participation.has_response_form?
                         absolute_path = Pathname(participation.consultation_response_form.file.url)
                         parent_path = Pathname('/government/uploads/')
                         child_path = absolute_path.relative_path_from(parent_path)
                         extension = child_path.extname

                         Whitehall.url_maker.public_upload_url(
                           File.join(
                             child_path.dirname,
                             child_path.basename(extension),
                           ),
                           {
                             extension: extension.delete('.'),
                           },
                         )
                       end

      email = participation.email if participation.has_email?
      link_url = participation.link_url if participation.has_link?

      postal_address = if participation.has_postal_address?
                         participation.postal_address
                       end

      {
        'ways_to_respond' => {
          'attachment_url' => attachment_url,
          'email' => email,
          'link_url' => link_url,
          'postal_address' => postal_address,
        }.compact
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
