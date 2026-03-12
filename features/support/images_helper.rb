module ImagesHelper
  def upload_fixture(filename, mime_type = nil)
    Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures", filename), mime_type)
  end
end

World(ImagesHelper)
