class Admin::BulkUploadsController < Admin::BaseController
  before_action :find_edition
  before_action :limit_edition_access!
  before_action :enforce_permissions!
  before_action :prevent_modification_of_unmodifiable_edition
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
      redirect_to admin_edition_attachments_path(@edition)
    else
      render :set_titles
    end
  end

private

  def build_bulk_upload
    @bulk_upload = BulkUpload.new(@edition)
  end

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
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
