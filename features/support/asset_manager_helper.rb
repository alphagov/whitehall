require_relative "mocha"

class MockAssetManager
  def create_asset(*args)
    { "id" => "http://asset-manager/assets/#{SecureRandom.uuid}", "name" => File.basename(args[0][:file]) }
  end

  def asset(id)
    { "id" => "http://asset-manager/asset/#{id}", "name" => "filename.pdf" }
  end

  def delete_asset(*_args); end

  def update_asset(*_args); end

  def media(*_args)
    response = OpenStruct.new
    response.body = File.read(File.open(Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg")))
    response
  end
end

Before do
  Services.stubs(:asset_manager).returns(MockAssetManager.new)
end
