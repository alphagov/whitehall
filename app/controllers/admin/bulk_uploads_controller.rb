class Admin::BulkUploadsController < Admin::BaseController
  before_filter :find_edition
  before_filter :limit_edition_access!
  before_filter :enforce_permissions!
  before_filter :prevent_modification_of_unmodifiable_edition

  def new
    @zip_file = BulkUpload::ZipFile.new
  end

  def upload_zip
    filename = params.fetch(:bulk_upload_zip_file, {})[:zip_file]
    @zip_file = BulkUpload::ZipFile.new(filename)
    if @zip_file.valid?
      @bulk_upload = BulkUpload.from_files(@edition, @zip_file.extracted_file_paths)
      @zip_file.cleanup_extracted_files
      render :set_titles
    else
      render :new
    end
  end

  def create
    @bulk_upload = BulkUpload.new(@edition)
    @bulk_upload.attachments_attributes = create_params[:bulk_upload][:attachments_attributes]
    if @bulk_upload.save_attachments
      redirect_to admin_edition_attachments_path(@edition)
    else
      render :set_titles
    end
  end

  private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end

  def create_params
    params.permit(:edition_id, bulk_upload: {attachments_attributes:
      [:title, {attachment_data_attributes: :file_cache}]})
  end
end
