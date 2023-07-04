desc "Validate Asset relationship for AttachmentData"

def asset_manager
  Services.asset_manager
end

def isOriginal(asset)
  asset.variant.eql?("original")
end

def isLegacyUrlPathSame(legacy_url_path_in_attachment_data, legacy_url_path_in_asset_manager)
  puts "AD path is #{legacy_url_path_in_attachment_data}"
  puts "AM path is #{legacy_url_path_in_asset_manager}"
  legacy_url_path_in_attachment_data == legacy_url_path_in_asset_manager
end

def validation_log(expect)
  if expect
    puts "legacy url matches for both AttachmentData and AssetManager"
  end
end

def legacy_url_asset_manager(asset)
  response_hash = asset_manager.asset(asset.asset_manager_id)
  path = response_hash["file_url"][/\/static.dev.gov.uk\/(.*)/, 1]
  "/#{path}"
end

# idea of the test is to randomly check for 100 newly created assets that they are as expected
# if the asset is as expected then it should have same legacy path in Asset Manager and Attachment Data
# legacy path from asset manager is returned as a part of file_url in response
# this test is only intended to run once in integration

task test_asset_migration: :environment do

  length = Asset.count

  mismatch_array = Array.new
  100.times do
    random_number_as_id = Random.new.rand(1..length)
    asset = Asset.find(random_number_as_id)
    attachment_data = AttachmentData.find(asset.attachment_data_id)

    if isOriginal(asset)
      expect = isLegacyUrlPathSame(attachment_data.file.path, legacy_url_asset_manager(asset))
      validation_log(expect)
    else
      expect = isLegacyUrlPathSame(attachment_data.file.thumbnail.path, legacy_url_asset_manager(asset))
      puts "legacy url matches for both AttachmentData and AssetManager"
    end

    if !expect
      mismatch_array << random_number_as_id
    end
  end

  if mismatch_array.size > 0
    puts "All assets in Assets are not as expected, there is a mismatch for ids: #{mismatch_array}"
  else
    puts "All assets in Assets are as expected"
  end
end
