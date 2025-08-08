class Admin::BulkUploadsController < Admin::AttachmentsController
  before_action :build_bulk_upload

  def new; end

  def upload_files
    @bulk_upload.build_attachments_from_files(files_params)

    if @bulk_upload.errors.present?
      render :new
    else
      render :set_titles
    end
  end

  def create
    @bulk_upload.build_attachments_from_params(attachments_params)

    if @bulk_upload.save_attachments
      @bulk_upload.attachments.each do |attachment|
        attachable_draft_updater
        attachment_updater(attachment.attachment_data)
      end

      redirect_to attachable_attachments_path(attachable)
    else
      render :set_titles
    end
  end

private

  def build_attachment
    FileAttachment.new(attachable:)
  end

  def build_bulk_upload
    @bulk_upload = BulkUpload.new(attachable)
  end

  def files_params
    params.fetch(:bulk_upload, {})[:files]
  end

  def attachments_params
    create_params.fetch(:attachments, [])
  end

  def create_params
    params.fetch(:bulk_upload).permit(attachments: [
      { attachment_data_attributes: %i[file_cache to_replace_id] },
      :id,
      :title,
      :locale,
      :isbn,
      :unique_reference,
      :command_paper_number,
      :unnumbered_command_paper,
      :hoc_paper_number,
      :unnumbered_hoc_paper,
      :parliamentary_session,
      :accessible,
    ])
  end
end
