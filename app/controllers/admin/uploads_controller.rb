class Admin::UploadsController < Admin::AttachmentsController
  before_action :build_upload
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  attr_accessor :output_buffer

  def upload_files
    @upload.build_attachments_from_files(files_params)

    if @upload.errors.present?
      redirect_to_attachments_index(upload_error: @upload.errors.full_messages.first)
    else
      render :set_titles
    end
  end

  def create
    if attachments_params_for_upload.blank?
      flash[:notice] = "No files uploaded"
      redirect_to_attachments_index
    else
      @upload.build_attachments_from_params(attachments_params_for_upload)

      if @upload.save_attachments
        @upload.attachments.each do |attachment|
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
  end

private

  def notice
    content_tag(:ul) do
      @upload.attachments.each do |attachment|
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

  def build_upload
    @upload = Upload.new(attachable)
  end

  def files_params
    params.fetch(:upload, {})[:files]
  end

  def attachments_params_for_upload
    attachments_params.except(*attachments_params.keys.select { |key| attachments_params[key][:attachment_data_attributes][:keep_or_replace] == "reject" })
  end

  def attachments_params
    create_params.fetch(:attachments, [])
  end

  def create_params
    params.fetch(:upload).permit(attachments: [
      { attachment_data_attributes: %i[file_cache to_replace_id keep_or_replace new_filename] },
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
