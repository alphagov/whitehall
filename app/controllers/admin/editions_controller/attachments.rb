module Admin::EditionsController::Attachments
  extend ActiveSupport::Concern

  included do
    before_filter :build_edition_attachment, only: [:new, :edit]
    before_filter :cope_with_attachment_action_params, only: [:update]
    before_filter :build_bulk_uploader, only: [:new, :edit]
    before_filter :extract_attachments_from_zip_file, only: [:create, :update]
  end

  def build_edition_dependencies
    super
    build_edition_attachment
  end

  def build_edition_attachment
    @edition.build_empty_attachment
  end

  def cope_with_attachment_action_params
    return unless params[:edition] && params[:edition][:edition_attachments_attributes]
    params[:edition][:edition_attachments_attributes].each do |_, edition_attachment_params|
      Admin::AttachmentActionParamHandler.manipulate_params!(edition_attachment_params)
    end
  end

  def build_bulk_uploader
    @bulk_upload_zip_file = BulkUpload::ZipFile.new(nil)
  end

  def extract_attachments_from_zip_file
    return unless params[:attachment_mode] == 'bulk'
    @bulk_upload_zip_file = BulkUpload::ZipFile.new((params[:bulk_upload_zip_file] || {} )[:zip_file])
    unless @bulk_upload_zip_file.valid?
      @edition.attributes = params[:edition]
      @edition.errors.add(:bulk_upload_zip_file, 'is invalid')
      render @edition.new_record? ? :new : :edit
    end
  end
end
