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

  test "raises exception if no attributes are supplied" do
    assert_raises(AssetManager::AssetUpdater::AssetAttributesEmpty) do
      @asset_updater.call(@asset_manager_id, {})
    end
  end

  test "raises exception if attempting to update a live deleted asset" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id)
           .returns("id" => @asset_manager_id, "deleted" => true, "draft" => false)

    assert_raises(AssetManager::AssetUpdater::AssetDeleted) do
      @asset_updater.call(@asset_manager_id, { "redirect_url" => @redirect_url })
    end
  end

  test "rescues and logs if attempting to update a live asset with a draft `parent_document_url`" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id).returns("id" => @asset_manager_id, "parent_document_url" => "gov.uk/live-parent", "draft" => false)
    Services.asset_manager.expects(:update_asset).with(@asset_manager_id, { "parent_document_url" => "draft-origin/parent" }).raises(GdsApi::HTTPUnprocessableEntity, "Parent document url must be a public GOV.UK URL")

    Rails.logger.expects(:info).with("Attempted to update Asset with asset_manager_id: '#{@asset_manager_id}' that is live, with a draft 'parent_document_url'")

    @asset_updater.call(@asset_manager_id, { "parent_document_url" => "draft-origin/parent" })
  end

  test "bubbles up unprocessable entity errors that are not about the 'parent_document_url'" do
    @asset_updater.stubs(:find_asset_by_id).with(@asset_manager_id).returns("id" => @asset_manager_id)
    Services.asset_manager.expects(:update_asset).raises(GdsApi::HTTPUnprocessableEntity, "Error")

    assert_raises GdsApi::HTTPUnprocessableEntity, "Error" do
      @asset_updater.call(@asset_manager_id, { draft: false })
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
