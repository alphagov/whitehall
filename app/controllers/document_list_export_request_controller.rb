class DocumentListExportRequestController < ApplicationController
  def show
    filename = "document_list_#{document_type_slug}_#{params[:export_id]}.csv"

    begin
      file = get_csv_file_from_s3(filename)
      send_data(file, filename: filename)
    rescue Fog::AWS::Storage::NotFound
      head :not_found
    end
  end

  def check_authorisation
    document_slugs = FinderSchema.schema_names.map { |schema_name| schema_name.singularize.camelize.constantize }
    current_format = document_slugs.detect { |model| model.slug == document_type_slug }
    authorize current_format
  end

  def get_csv_file_from_s3(filename)
    connection = Fog::Storage.new(
      provider: "AWS",
      region: ENV["AWS_REGION"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )

    directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])

    file = directory.files.get(filename)

    raise Fog::AWS::Storage::NotFound, "Object #{filename} does not exist." if file.nil?

    file.body
  end
end
