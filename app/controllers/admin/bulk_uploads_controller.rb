class Admin::BulkUploadsController < Admin::BaseController
	before_filter :find_edition
  before_filter :limit_edition_access!
  before_filter :enforce_permissions!

	def new
		@bulk_upload_zip_file = BulkUpload::ZipFile.new
	end

	def upload_zip
		@bulk_upload_zip_file = BulkUpload::ZipFile.new(params[:bulk_upload_zip_file][:zip_file])
		if @bulk_upload_zip_file.valid?
			@bulk_upload = BulkUpload.from_files(@bulk_upload_zip_file.extracted_file_paths)
			render :set_titles
		else
			render :new
		end
	end

	def create
		@bulk_upload = BulkUpload.new(params[:bulk_upload])
		if @bulk_upload.save_attachments_to_edition(@edition)
			redirect_to edit_admin_edition_path(@edition)
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
end
