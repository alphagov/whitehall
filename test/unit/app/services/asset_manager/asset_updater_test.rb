require "test_helper"

class AssetManager::AssetUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @asset_manager_id = "asset-id"
    @asset_url = "http://asset-manager/assets/#{@asset_manager_id}"
    @asset_updater = AssetManager::AssetUpdater.new
    @redirect_url = "https://www.test.gov.uk/example"
    @attachment_data = FactoryBot.build(:attachment_data)
  end

  test "updates auth_bypass_ids for ImageData" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => true)

    Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "auth_bypass_ids" => [] })

    @asset_updater.call(@asset_manager_id, { "auth_bypass_ids" => [] })
  end

  test "does not update asset if no attributes are supplied" do
    assert_raises(AssetManager::AssetUpdater::AssetAttributesEmpty) do
      @asset_updater.call(@asset_manager_id, {})
    end
  end

  test "marks draft asset as published" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => true)
    Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "draft" => false })

    @asset_updater.call(@asset_manager_id, { "draft" => false })
  end

  test "does not mark asset as published if already published" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => false)
    Services.asset_manager.expects(:update_asset).never

    @asset_updater.call(@asset_manager_id, { "draft" => false })
  end

  test "mark published asset as draft" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => false)
    Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "draft" => true })

    @asset_updater.call(@asset_manager_id, { "draft" => true })
  end

  test "does not mark asset as draft if already draft" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "draft" => true)
    Services.asset_manager.expects(:update_asset).never

    @asset_updater.call(@asset_manager_id, { "draft" => true })
  end

  test "sets redirect_url on asset if not already set" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id)
    Services.asset_manager.expects(:update_asset)
            .with(@asset_manager_id, { "redirect_url" => @redirect_url })

    @asset_updater.call(@asset_manager_id, { "redirect_url" => @redirect_url })
  end

  test "sets redirect_url on asset if already set to different value" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "redirect_url" => "#{@redirect_url}-another")
    Services.asset_manager.expects(:update_asset)
            .with(@asset_manager_id, { "redirect_url" => @redirect_url })

    @asset_updater.call(@asset_manager_id, { "redirect_url" => @redirect_url })
  end

  test "does not set redirect_url on asset if already set" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "redirect_url" => @redirect_url)
    Services.asset_manager.expects(:update_asset).never

    @asset_updater.call(@asset_manager_id, { "redirect_url" => @redirect_url })
  end

  test "marks asset as access-limited" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id)
    Services.asset_manager.expects(:update_asset)
            .with(@asset_manager_id, { "access_limited" => %w[uid-1] })

    @asset_updater.call(@asset_manager_id, { "access_limited" => %w[uid-1] })
  end

  test "does not mark asset as access-limited if already set" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "access_limited" => %w[uid-1])
    Services.asset_manager.expects(:update_asset).never

    @asset_updater.call(@asset_manager_id, { "access_limited" => %w[uid-1] })
  end

  test "marks asset as replaced by another asset" do
    replacement_id = "replacement-id"
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id)
    Services.asset_manager.expects(:update_asset)
            .with(@asset_manager_id, { "replacement_id" => replacement_id })

    attributes = { "replacement_id" => replacement_id }
    @asset_updater.call(@asset_manager_id, attributes)
  end

  test "does not mark asset as replaced if already replaced by same asset" do
    replacement_id = "replacement-id"
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "replacement_id" => replacement_id)
    Services.asset_manager.expects(:update_asset).never

    attributes = { "replacement_id" => replacement_id }
    @asset_updater.call(@asset_manager_id, attributes)
  end
end
