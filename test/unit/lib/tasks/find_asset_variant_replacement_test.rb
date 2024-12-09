require "test_helper"
require "rake"

class FixAssetVariantReplacementTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#fix_asset_variant_replacement" do
    let(:task) { Rake::Task["fix_asset_variant_replacement"] }
    let(:file) { Tempfile.new("read_assets_file") }
    let(:filepath) { file.path }
    let(:attachable) { create(:news_article) }
    let(:attachment_data) { create(:attachment_data, id: 123_456, attachable:) }
    let(:replacement_data) { create(:attachment_data, attachable:) }
    let(:replacement_data2) { create(:attachment_data, attachable:) }
    let(:original_asset) { attachment_data.assets.original.first }
    let(:thumbnail_asset) { attachment_data.assets.thumbnail.first }
    let(:replacement_original_asset) { replacement_data2.assets.original.first }
    let(:replacement_thumbnail_asset) { replacement_data2.assets.thumbnail.first }

    teardown { task.reenable }

    before do
      csv_file = <<~CSV
        123456,1592008029c8c3e4dc76256c,original
        123456,1592008029c8c3e4dc76256d,thumbnail
      CSV
      file.write(csv_file)
      file.close

      attachment_data.replaced_by = replacement_data
      replacement_data.replaced_by = replacement_data2

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

    test "it sends the last replacement in the chain to asset-manager" do
      Services.asset_manager.stubs(:asset).with(original_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{original_asset.asset_manager_id}", "name" => "original.pdf")
      Services.asset_manager.stubs(:asset).with(thumbnail_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{thumbnail_asset.asset_manager_id}", "name" => "thumbnail.pdf.png")

      expected_output = <<~OUTPUT
        Attachment Data ID: #{attachment_data.id}, Asset ID: #{original_asset.asset_manager_id}, Variant: #{original_asset.variant}, Replacement ID: #{replacement_original_asset.asset_manager_id} - OK
        Attachment Data ID: #{attachment_data.id}, Asset ID: #{thumbnail_asset.asset_manager_id}, Variant: #{thumbnail_asset.variant}, Replacement ID: #{replacement_thumbnail_asset.asset_manager_id} - OK
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

    test "it sends original replacement if thumbnail is missing" do
      replacement_thumbnail_asset.destroy!

      Services.asset_manager.stubs(:asset).with(original_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{original_asset.asset_manager_id}", "name" => "original.pdf")
      Services.asset_manager.stubs(:asset).with(thumbnail_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{thumbnail_asset.asset_manager_id}", "name" => "thumbnail.pdf.png")

      expected_output = <<~OUTPUT
        Attachment Data ID: #{attachment_data.id}, Asset ID: #{original_asset.asset_manager_id}, Variant: #{original_asset.variant}, Replacement ID: #{replacement_original_asset.asset_manager_id} - OK
        Attachment Data ID: #{attachment_data.id}, Asset ID: #{thumbnail_asset.asset_manager_id}, Variant: #{thumbnail_asset.variant}, Replacement ID: #{replacement_original_asset.asset_manager_id} - OK
      OUTPUT
      Services.asset_manager.expects(:update_asset)
              .at_least_once
              .with(original_asset.asset_manager_id, { "replacement_id" => replacement_original_asset.asset_manager_id })

      Services.asset_manager.expects(:update_asset)
              .at_least_once
              .with(thumbnail_asset.asset_manager_id, { "replacement_id" => replacement_original_asset.asset_manager_id })

      output, _err = capture_io { task.invoke(filepath) }
      assert_equal expected_output, output
    end

    test "it skips and logs if no replacement is found" do
      attachment_data.replaced_by_id = nil
      attachment_data.save!

      expected_output = <<~OUTPUT
        Attachment Data ID: #{attachment_data.id}, Asset ID: #{original_asset.asset_manager_id} - SKIPPED. No replacement found.
        Attachment Data ID: #{attachment_data.id}, Asset ID: #{thumbnail_asset.asset_manager_id} - SKIPPED. No replacement found.
      OUTPUT

      output, _err = capture_io { task.invoke(filepath) }
      assert_equal expected_output, output
    end

    test "it logs error if asset not found" do
      error = GdsApi::HTTPClientError.new(404, "Not found")
      Services.asset_manager.expects(:asset).with(original_asset.asset_manager_id).raises(error)
      Services.asset_manager.stubs(:asset).with(thumbnail_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{thumbnail_asset.asset_manager_id}", "name" => "thumbnail.pdf.png")
      Services.asset_manager.stubs(:update_asset).with(thumbnail_asset.asset_manager_id, { "replacement_id" => replacement_original_asset.asset_manager_id }).raises(error)

      expected_output = <<~OUTPUT
        Attachment Data ID: #{attachment_data.id}, Asset ID #{original_asset.asset_manager_id} - ERROR, message: #{error.message}
        Attachment Data ID: #{attachment_data.id}, Asset ID: #{thumbnail_asset.asset_manager_id}, Variant: #{thumbnail_asset.variant}, Replacement ID: #{replacement_thumbnail_asset.asset_manager_id} - OK
      OUTPUT

      output, _err = capture_io { task.invoke(filepath) }
      assert_equal expected_output, output
    end

    test "it logs error if update fails" do
      error = GdsApi::HTTPClientError.new(500, "Server error")
      Services.asset_manager.stubs(:asset).with(original_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{original_asset.asset_manager_id}", "name" => "original.pdf", "replacement_id" => nil)
      Services.asset_manager.stubs(:asset).with(thumbnail_asset.asset_manager_id).returns("id" => "http://asset-manager/assets/#{thumbnail_asset.asset_manager_id}", "name" => "thumbnail.pdf.png")
      Services.asset_manager.stubs(:update_asset).with(original_asset.asset_manager_id, { "replacement_id" => replacement_original_asset.asset_manager_id }).raises(error)
      Services.asset_manager.stubs(:update_asset).with(thumbnail_asset.asset_manager_id, { "replacement_id" => replacement_thumbnail_asset.asset_manager_id })

      expected_output = <<~OUTPUT
        Attachment Data ID: #{attachment_data.id}, Asset ID #{original_asset.asset_manager_id} - ERROR, message: Server error
        Attachment Data ID: #{attachment_data.id}, Asset ID: #{thumbnail_asset.asset_manager_id}, Variant: #{thumbnail_asset.variant}, Replacement ID: #{replacement_thumbnail_asset.asset_manager_id} - OK
      OUTPUT

      output, _err = capture_io { task.invoke(filepath) }
      assert_equal expected_output, output
    end
  end
end
