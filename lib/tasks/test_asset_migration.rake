def asset_manager
  Services.asset_manager
end

def is_original(asset)
  asset.variant.eql?("original")
end

def is_legacy_url_path_same(legacy_url_path_in_attachment_data, legacy_url_path_in_asset_manager)
  puts "Whitehall path is    #{legacy_url_path_in_attachment_data}"
  puts "AssetManager path is #{legacy_url_path_in_asset_manager}"
  legacy_url_path_in_attachment_data == legacy_url_path_in_asset_manager
end

def validation_log(expect, assetable_type)
  if expect
    puts "legacy url matches for both #{assetable_type} and AssetManager"
  end
end

def legacy_url_asset_manager(asset)
  response_hash = asset_manager.asset(asset.asset_manager_id)
  path = response_hash["file_url"][/\/static.dev.gov.uk\/(.*)/, 1]
  "/#{path}"
end

# The idea of the test is to randomly check for 100 newly created assets that they are as expected.
# If the asset is as expected then it should have same legacy path in Asset Manager and Attachment Data
# legacy path from asset manager is returned as a part of file_url in response.
# This test is only intended to run once in integration
desc "Validate Asset relationship for AttachmentData"
task test_asset_migration: :environment do
  length = Asset.last.id

  mismatch_array = []
  assetable_type = AttachmentData

  100.times do
    random_number_as_id = Random.new.rand(1..length)

    begin
      asset = Asset.find(random_number_as_id)
      if asset
        attachment_data = assetable_type.find(asset.assetable_id)

        if is_original(asset)
          expect = is_legacy_url_path_same(attachment_data.file.path, legacy_url_asset_manager(asset))
          validation_log(expect, assetable_type.to_s)
        else
          expect = is_legacy_url_path_same(attachment_data.file.thumbnail.path, legacy_url_asset_manager(asset))
          puts "legacy url matches for both #{assetable_type} and AssetManager"
        end

        unless expect
          mismatch_array << random_number_as_id
        end
      end
    rescue ActiveRecord::RecordNotFound
      puts "Asset not found for asset id: #{random_number_as_id}"
    end
  end

  if mismatch_array.size.positive?
    puts "All assets in Assets are not as expected, there is a mismatch for ids: #{mismatch_array}"
  else
    puts "All assets in Assets are as expected"
  end
end
