require 'csv'

class PublicationUploader
  def initialize(options = {})
    @csv_data = options[:csv_data]
    @creator = options[:import_as] || User.find_by_name!("Automatic Data Importer")
    @logger = options[:logger] || Logger.new($stdout)
  end

  def upload
    uploader = Whitehall::Uploader::Csv.new(@csv_data, PublicationRow, Publication, @logger)
    uploader.import_as(@creator)
  end
end
