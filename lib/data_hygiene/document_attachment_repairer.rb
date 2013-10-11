module DataHygiene
  class DocumentAttachmentRepairer
    attr_reader :document, :user, :logger

    def initialize(document, user, logger)
      @document = document
      @user = user
      @logger = logger
    end

    def repair_attachments!
      Edition::AuditTrail.acting_as(user) do
        if document_published_with_newer_draft?
          repair_published_with_draft_document
        elsif document_published?
          repair_published_document
        else
          repair_draft_document
        end
      end
    end

    private

    def document_published_with_newer_draft?
      document_published? && document.published_edition != document.latest_edition
    end

    def document_published?
      document.published_edition
    end

    def repair_published_with_draft_document
      return unless has_attachments_requiring_repair?
      logger.info "Repairing published document with newer draft (#{@document.id})"

      document.latest_edition.attachments.each do |attachment|
        if attachment_needs_repairing?(attachment)
          replace_attachment_data(attachment)
        end
      end

      add_remark_to_latest_edition('Updated with corrected attachment filename(s)')
    end

    def repair_published_document
      return unless has_attachments_requiring_repair?
      logger.info "Repairing published document (#{@document.id})"

      # create new draft
      new_edition = document.latest_edition.create_draft(user)

      # repair filename(s)
      new_edition.attachments.each do |attachment|
        if attachment_needs_repairing?(attachment)
          replace_attachment_data(attachment)
        end
      end

      # Force a reload in case the counter cache has incremented the
      # lock_version
      # XXX: this may be a bug in Rails' optimistic locking

      new_edition = new_edition.reload
      new_edition.minor_change = true
      new_edition.skip_virus_status_check = true

      # publish
      reason = 'Re-editioned with corrected attachment filename(s)'
      if EditionForcePublisher.new(new_edition, user, reason)
        add_remark_to_latest_edition(reason)
      else
        logger.error("Error: Document (#{document.id}) could not be published: #{new_edition.errors.full_messages.to_sentence}")
      end

    rescue ActiveRecord::StaleObjectError => e
      logger.error("Error: Document (#{document.id}) locked. Could not fixed and re-published")
    end

    def repair_draft_document
      return unless has_attachments_requiring_repair?
      logger.info "Repairing draft document (#{@document.id})"

      document.latest_edition.attachments.each do |attachment|
        if attachment_needs_repairing?(attachment)
          update_attachment_data_file(attachment)
        end
      end

      add_remark_to_latest_edition('Updated with corrected attachment filename(s)')
    end

    # If we are re-editioning the document, or it is already being re-editioned, we replace the attachment
    # data for the attachment and make sure the old one points at this replacement.
    def replace_attachment_data(attachment)
      corrected_tmp_file = repaired_file_for(attachment)
      logger.info("\tAttachment #{attachment.filename} (#{attachment.id}) being replaced with #{File.basename(corrected_tmp_file.path)}")

      attachment.attachment_data = AttachmentData.new(file: corrected_tmp_file, to_replace_id: attachment.attachment_data_id)
      attachment.save!
    ensure
      FileUtils.rm(corrected_tmp_file.path)
    end

    # If we are dealing with a draft document, we can simply rename and replace the file directly, as we
    # do not have to worry about redirects as the file will not be linked to yet in the wild.
    def update_attachment_data_file(attachment)
      corrected_tmp_file = repaired_file_for(attachment)
      logger.info("\tAttachment #{attachment.filename} (#{attachment.id}) being updated to #{File.basename(corrected_tmp_file.path)}")

      attachment.attachment_data.file = corrected_tmp_file
      attachment.attachment_data.save!
    ensure
      FileUtils.rm(corrected_tmp_file.path)
    end

    def repaired_file_for(attachment)
      tmp_file_path = Rails.root.join('tmp', corrected_filename(attachment.filename))
      FileUtils.copy(attachment.attachment_data.file.path, tmp_file_path)
      File.open(tmp_file_path)
    end

    def attachment_needs_repairing?(attachment)
      if File.exists?(attachment.file.path)
        filename_needs_repairing?(attachment.filename) && !attachment.attachment_data.replaced_by.present?
      else
        logger.warn("\tWarning: Attachment (#{attachment.id}) file not found on the file system")
        false
      end
    end

    def filename_needs_repairing?(filename)
      filename != corrected_filename(filename)
    end

    def has_attachments_requiring_repair?
      if document.latest_edition.attachments.any? { |attachment| attachment_needs_repairing?(attachment) }
        true
      else
        logger.info("Attachements on the latest edition of Document (#{document.id}) are either fine or have already been repaired")
        false
      end
    end

    def corrected_filename(filename)
      extension = File.extname(filename)
      filename.gsub(/(#{extension}){2,}$/, extension)
    end

    def add_remark_to_latest_edition(remark)
      document.latest_edition(true).editorial_remarks.create(body: remark, author: user)
    end
  end
end
