require "test_helper"

class AssetManager::AssetUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @asset_manager_id = "asset-id"
    @asset_url = "http://asset-manager/assets/#{@asset_manager_id}"
    @worker = AssetManager::AssetUpdater.new
    @redirect_url = "https://www.test.gov.uk/example"
    @attachment_data = FactoryBot.build(:attachment_data)
  end

  test "updates auth_bypass_ids for ImageData" do
    image_data = build(:image_data)
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => true)

    Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "auth_bypass_ids" => [] })

    @worker.call(@asset_manager_id, image_data, { "auth_bypass_ids" => [] })
  end

  test "raises exception if asset has been deleted in asset manager and attachment_data isn't deleted" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_url, "deleted" => true)
    @attachment_data.stubs(:deleted?).returns(false)

    assert_raises(AssetManager::AssetUpdater::AssetAlreadyDeleted) do
      @worker.call(@asset_manager_id, @attachment_data, { "draft" => false })
    end
  end

  test "does not update asset if no attributes are supplied" do
    assert_raises(AssetManager::AssetUpdater::AssetAttributesEmpty) do
      @worker.call(@asset_manager_id, @attachment_data)
    end
  end

  test "marks draft asset as published" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => true)
    Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "draft" => false })

    @worker.call(@asset_manager_id, @attachment_data, { "draft" => false })
  end

  test "does not mark asset as published if already published" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => false)
    Services.asset_manager.expects(:update_asset).never

    @worker.call(@asset_manager_id, @attachment_data, { "draft" => false })
  end

  test "mark published asset as draft" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => false)
    Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "draft" => true })

    @worker.call(@asset_manager_id, @attachment_data, { "draft" => true })
  end

  test "does not mark asset as draft if already draft" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => true)
    Services.asset_manager.expects(:update_asset).never

    @worker.call(@asset_manager_id, @attachment_data, { "draft" => true })
  end

  test "sets redirect_url on asset if not already set" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id)
    Services.asset_manager.expects(:update_asset)
            .with(@asset_manager_id, { "redirect_url" => @redirect_url })

    @worker.call(@asset_manager_id, @attachment_data, { "redirect_url" => @redirect_url })
  end

  test "sets redirect_url on asset if already set to different value" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "redirect_url" => "#{@redirect_url}-another")
    Services.asset_manager.expects(:update_asset)
            .with(@asset_manager_id, { "redirect_url" => @redirect_url })

    @worker.call(@asset_manager_id, @attachment_data, { "redirect_url" => @redirect_url })
  end

  test "does not set redirect_url on asset if already set" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "redirect_url" => @redirect_url)
    Services.asset_manager.expects(:update_asset).never

    @worker.call(@asset_manager_id, @attachment_data, { "redirect_url" => @redirect_url })
  end

  test "marks asset as access-limited" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id)
    Services.asset_manager.expects(:update_asset)
            .with(@asset_manager_id, { "access_limited" => %w[uid-1] })

    @worker.call(@asset_manager_id, @attachment_data, { "access_limited" => %w[uid-1] })
  end

  test "does not mark asset as access-limited if already set" do
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "access_limited" => %w[uid-1])
    Services.asset_manager.expects(:update_asset).never

    @worker.call(@asset_manager_id, @attachment_data, { "access_limited" => %w[uid-1] })
  end

  test "marks asset as replaced by another asset" do
    replacement_id = "replacement-id"
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id)
    Services.asset_manager.expects(:update_asset)
            .with(@asset_manager_id, { "replacement_id" => replacement_id })

    attributes = { "replacement_id" => replacement_id }
    @worker.call(@asset_manager_id, @attachment_data, attributes)
  end

  test "does not mark asset as replaced if already replaced by same asset" do
    replacement_id = "replacement-id"
    @worker.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "replacement_id" => replacement_id)
    Services.asset_manager.expects(:update_asset).never

    attributes = { "replacement_id" => replacement_id }
    @worker.call(@asset_manager_id, @attachment_data, attributes)
  end
end
