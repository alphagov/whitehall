require "test_helper"

class AssetManager::AssetRestorerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @asset_manager_id = "asset-id"
    @redirect_url = "https://www.gov.uk/example"
    @job = AssetManager::AssetRestorer.new
  end

  def stub_asset(attributes)
    @job.stubs(:find_asset_by_id).with(@asset_manager_id).returns({ "id" => @asset_manager_id }.merge(attributes))
  end

  describe "called with a redirect_url" do
    test "restores a deleted asset before setting its redirect_url" do
      stub_asset("deleted" => true)

      restore = sequence("restore")
      Services.asset_manager.expects(:restore_asset).with(@asset_manager_id).in_sequence(restore)
      Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "redirect_url" => @redirect_url }).in_sequence(restore)

      @job.call(@asset_manager_id, @redirect_url)
    end

    test "does not attempt a restore if the asset is not deleted" do
      stub_asset("deleted" => false)

      Services.asset_manager.expects(:restore_asset).never
      Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "redirect_url" => @redirect_url })

      @job.call(@asset_manager_id, @redirect_url)
    end

    test "overwrites a different redirect_url" do
      stub_asset("deleted" => false, "redirect_url" => "https://www.gov.uk/stale")

      Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "redirect_url" => @redirect_url })

      @job.call(@asset_manager_id, @redirect_url)
    end

    test "does not update the redirect_url if it is already set" do
      stub_asset("deleted" => false, "redirect_url" => @redirect_url)

      Services.asset_manager.expects(:restore_asset).never
      Services.asset_manager.expects(:update_asset).never

      @job.call(@asset_manager_id, @redirect_url)
    end
  end

  describe "called with a nil redirect_url" do
    test "restores a deleted asset and clears its redirect_url" do
      stub_asset("deleted" => true, "redirect_url" => @redirect_url)

      restore = sequence("restore")
      Services.asset_manager.expects(:restore_asset).with(@asset_manager_id).in_sequence(restore)
      Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "redirect_url" => nil }).in_sequence(restore)

      @job.call(@asset_manager_id, nil)
    end

    test "does not update the redirect_url if none is set" do
      stub_asset("deleted" => true)

      Services.asset_manager.expects(:restore_asset).with(@asset_manager_id)
      Services.asset_manager.expects(:update_asset).never

      @job.call(@asset_manager_id, nil)
    end
  end
end
