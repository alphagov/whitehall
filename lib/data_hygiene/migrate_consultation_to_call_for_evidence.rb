module DataHygiene
  class MigrateConsultationToCallForEvidence
    IGNORE_ASSOCIATION_ATTRIBUTES = %w[id edition_id type].freeze

    attr_reader :document, :whodunnit, :call_for_evidence, :consultation, :draft_consultation

    def initialize(document:, whodunnit:)
      @document = document
      @whodunnit = whodunnit

      if can_be_migrated?(document.latest_edition)
        @consultation = document.latest_edition
      else
        raise "Document cannot be migrated"
      end
    end

    def call
      AuditTrail.acting_as(whodunnit) do
        document.transaction do
          create_draft_call_for_evidence
          migrate_outcome
          migrate_participation
          publish
          Whitehall::SearchIndex.delete(@consultation)
        end
      end
    end

  private

    def can_be_migrated?(edition)
      edition.is_a?(Consultation) && edition.publicly_visible?
    end

    def create_draft_call_for_evidence
      @draft_consultation = consultation.create_draft(whodunnit)
      @call_for_evidence = @draft_consultation.becomes!(CallForEvidence)
      call_for_evidence.minor_change = true
      call_for_evidence.save!
    end

    def migrate_outcome
      return unless @draft_consultation.outcome || @draft_consultation.public_feedback

      source_outcome = @draft_consultation.outcome
      source_public_feedback = @draft_consultation.public_feedback
      destination = @call_for_evidence.build_outcome

      destination.assign_attributes association_attributes(source_outcome || source_public_feedback)

      # Merge 'Outcome' summary and 'Public Feedback' summary
      destination.summary = [source_outcome&.summary, source_public_feedback&.summary].compact.join("\n\n")

      # Copy 'Outcome' attachments, followed by 'Public Feedback' attachments
      [source_outcome, source_public_feedback].compact.each do |source|
        source.attachments.each do |attachment|
          destination.attachments << attachment.deep_clone
        end

        source.destroy!
      end

      # Set 'ordering' attributes correctly (they have to be unique)
      destination.attachments.each_with_index do |attachment, index|
        attachment.ordering = index
      end

      destination.save!
    end

    def migrate_participation
      return if @draft_consultation.consultation_participation.blank?

      source = @draft_consultation.consultation_participation
      destination = @call_for_evidence.build_call_for_evidence_participation

      destination.assign_attributes association_attributes(source, except: %w[consultation_response_form_id])

      if source.consultation_response_form.present?
        migrate_response_form(
          source: source.consultation_response_form,
          destination: destination.build_call_for_evidence_response_form,
        )
      end

      source.destroy!
      destination.save!
    end

    def migrate_response_form(source:, destination:)
      destination.title = source.title

      source_data = source.consultation_response_form_data
      destination_data = destination.build_call_for_evidence_response_form_data

      # Download the source file and set it as the destination file
      # This will be uploaded on the destination model when saved
      # Note: this will not redirect or replace the source file
      destination_data.file.download!(source_data.file.url)
    end

    def publish
      call_for_evidence.submit!
      publish_reason = "Consultation document type migrated to call for evidence document type"
      edition_publisher = Whitehall.edition_services.publisher(@call_for_evidence, user: @whodunnit, remark: publish_reason)
      edition_publisher.perform!
    end

    def association_attributes(old_object, except: [])
      old_object.attributes.except(*IGNORE_ASSOCIATION_ATTRIBUTES, *except)
    end
  end
end
