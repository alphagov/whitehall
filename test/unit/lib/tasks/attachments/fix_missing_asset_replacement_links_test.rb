require "test_helper"
require "rake"

class FixMissingAssetReplacementLinksTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "fix_missing_asset_replacement_links" do
    let(:task) { Rake::Task["fix_missing_asset_replacement_links"] }
    let(:file) { Tempfile.new("read_assets_file") }
    let(:filepath) { file.path }
    let(:attachable) { create(:news_article) }
    let(:attachment_data) { create(:attachment_data, id: 123_456, attachable:) }
    let(:replacement_data) { create(:attachment_data, attachable:) }
    let(:replacement_data2) { create(:attachment_data, attachable:) }
    let(:original_asset) { attachment_data.assets.original.first }
    let(:thumbnail_asset) { attachment_data.assets.thumbnail.first }
    let(:replacement_original_asset) { replacement_data.assets.original.first }
    let(:replacement_thumbnail_asset) { replacement_data.assets.thumbnail.first }

    teardown { task.reenable }

    before do
      csv_file = <<~CSV
        123456
      CSV
      file.write(csv_file)
      file.close

      original_asset.asset_manager_id = "1592008029c8c3e4dc76256c"
      original_asset.save!
      thumbnail_asset.asset_manager_id = "1592008029c8c3e4dc76256d"
      thumbnail_asset.save!
      replacement_original_asset.asset_manager_id = "2592008029c8c3e4dc76256c"
      replacement_original_asset.save!
      replacement_thumbnail_asset.asset_manager_id = "2592008029c8c3e4dc76256d"
      replacement_thumbnail_asset.save!

      attachment_data.replaced_by = replacement_data
      replacement_data.replaced_by = replacement_data2
      attachment_data.save!
      replacement_data.save!
      replacement_data2.save!
    end

    test "it outputs AttachmentData ID and sends correct load" do
      Services.asset_manager.stubs(:asset).with(original_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{original_asset.asset_manager_id}", "name" => "original.pdf")
      Services.asset_manager.stubs(:asset).with(thumbnail_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{thumbnail_asset.asset_manager_id}", "name" => "thumbnail.pdf.png")

      expected_output = <<~OUTPUT
        OK - ad: #{attachment_data.id}
      OUTPUT

      Services.asset_manager.expects(:update_asset)
              .at_least_once
              .with(original_asset.asset_manager_id, { "replacement_id" => replacement_original_asset.asset_manager_id })

      Services.asset_manager.expects(:update_asset)
              .at_least_once
              .with(thumbnail_asset.asset_manager_id, { "replacement_id" => replacement_thumbnail_asset.asset_manager_id })

      output, _err = capture_io { task.invoke(filepath) }
      assert_equal expected_output, output
    end

    test "it logs if no replacement is found" do
      attachment_data.replaced_by_id = nil
      attachment_data.save!

      expected_output = <<~OUTPUT
        ERROR - ad: #{attachment_data.id} does not have a replacement.
      OUTPUT

      output, _err = capture_io { task.invoke(filepath) }
      assert_equal output, expected_output
    end

    test "it logs error if asset not found" do
      error = GdsApi::HTTPClientError.new(404, "Not found")
      Services.asset_manager.expects(:asset).with(original_asset.asset_manager_id).raises(error)

      expected_output = <<~OUTPUT
        ERROR - ad: #{attachment_data.id}, message: Not found
      OUTPUT

      output, _err = capture_io { task.invoke(filepath) }
      assert_equal expected_output, output
    end

    test "it logs error if update fails" do
      error = GdsApi::HTTPClientError.new(500, "Server error")
      Services.asset_manager.stubs(:asset).with(original_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{original_asset.asset_manager_id}", "name" => "original.pdf", "replacement_id" => nil)
      Services.asset_manager.stubs(:asset).with(thumbnail_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{thumbnail_asset.asset_manager_id}", "name" => "thumbnail.pdf.png")
      Services.asset_manager.stubs(:update_asset).with(original_asset.asset_manager_id, { "replacement_id" => replacement_original_asset.asset_manager_id }).raises(error)

      expected_output = <<~OUTPUT
        ERROR - ad: #{attachment_data.id}, message: Server error
      OUTPUT

      output, _err = capture_io { task.invoke(filepath) }
      assert_equal expected_output, output
    end
  end
end
