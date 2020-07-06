class DocumentListExportRequestController < ApplicationController
  def show
    if user_signed_in?
      filename = DocumentListExportPresenter.s3_filename(params[:document_type_slug], params[:export_id])

      begin
        file = get_csv_file_from_s3(filename)
        send_data(file, filename: filename)
      rescue Fog::AWS::Storage::NotFound
        head :not_found
      end
    else
      head :unauthorized
    end
  end

  def get_csv_file_from_s3(filename)
    params = if ENV.key? "AWS_ACCESS_KEY_ID"
               { aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
                 aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"] }
             else
               { use_iam_profile: true }
             end
    params.merge!({
      region: ENV["AWS_REGION"],

    })
    connection = Fog::AWS::Storage.new(params)

    directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])

    file = directory.files.get(filename)

    raise Fog::AWS::Storage::NotFound, "Object #{filename} does not exist." if file.nil?

    file.body
  end
end
