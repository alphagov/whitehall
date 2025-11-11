class Admin::BulkUploadsController < Admin::AttachmentsController
  before_action :build_bulk_upload
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  attr_accessor :output_buffer

  def upload_files
    @bulk_upload.build_attachments_from_files(files_params)

    if @bulk_upload.errors.present?
      redirect_to_attachments_index(bulk_upload_error: @bulk_upload.errors.full_messages.first)
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

      flash[:notice] = notice
      flash[:html_safe] = true

      redirect_to_attachments_index
    else
      render :set_titles
    end
  end

private

  def notice
    content_tag(:ul) do
      @bulk_upload.attachments.each do |attachment|
        concat content_tag(
          :li,
          "Attachment '#{attachment.title}' #{attachment.attachment_data.to_replace_id.present? ? 'updated' : 'uploaded'}".html_safe,
          class: "govuk-notification-banner__heading",
        )
      end
    end
  end

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
