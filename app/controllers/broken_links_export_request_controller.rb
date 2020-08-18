class BrokenLinksExportRequestController < ApplicationController
  def show
    if user_signed_in?
      filename = "broken-link-reports-#{params[:export_id]}.zip"

      begin
        file = S3FileHandler.get_file_from_s3(filename)
        send_data(file, filename: filename)
      rescue Fog::AWS::Storage::NotFound
        head :not_found
      end
    else
      head :unauthorized
    end
  end
end
