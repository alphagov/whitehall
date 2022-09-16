class DocumentListExportRequestController < ApplicationController
  def show
    if user_signed_in?
      filename = DocumentListExportPresenter.s3_filename(params[:document_type_slug], params[:export_id])

      if (file = S3FileHandler.get_file_from_s3(filename))
        send_data(file, filename:)
      else
        head :not_found
      end
    else
      head :unauthorized
    end
  end
end
