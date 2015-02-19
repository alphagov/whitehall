class NewsArticleUploader
  def initialize(options = {})
    @csv_data = options[:csv_data]
    @creator = options[:import_as] || User.find_by!(name: "Automatic Data Importer")
    @row_class = Whitehall::Uploader::NewsArticleRow
    @model_class = NewsArticle
    @logger = options[:logger] || Logger.new($stdout)
    @attachment_cache = Whitehall::Uploader::AttachmentCache.new(Whitehall::Uploader::AttachmentCache.default_root_directory, @logger)
    @error_csv_path = options[:error_csv_path]
  end

  def upload
    uploader = Whitehall::Uploader::Csv.new(@csv_data, @row_class, @model_class, @attachment_cache, @logger, @error_csv_path)
    uploader.import_as(@creator)
  end
end
