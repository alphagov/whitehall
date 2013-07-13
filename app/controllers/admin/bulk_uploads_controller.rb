class Admin::BulkUploadsController < Admin::BaseController
	before_filter :load_edition

	def new
		@bulk_upload_zip_file = BulkUpload::ZipFile.new(nil)
	end

	def upload_zip
		zip_file = BulkUpload::ZipFile.new(params[:bulk_upload_zip_file][:zip_file])
		@bulk_upload = BulkUpload.from_files(zip_file.extracted_file_paths)
		render :set_titles
	end

	def create
		# if save
		# 	redirect_to_edition
		# else
		# 	render :set_titles
		# end
	end

	private

	def load_edition
		@edition = Edition.find(params[:edition_id])
	end
end
