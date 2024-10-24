require "rake"
require "test_helper"
require "gds_api/test_helpers/asset_manager"

class AssetManagerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include GdsApi::TestHelpers::AssetManager

  let!(:task) { Rake::Task["asset_manager:report_deleted_assets"] }

  teardown do
    task.reenable
  end

  context "for an asset attached only to a superseded edition" do
    let!(:edition) { create(:superseded_publication) }
    let!(:attachment) { create(:file_attachment_with_asset, attachable: edition) }

    context "when asset is not deleted from asset manager" do
      before do
        attachment.attachment_data.assets.each do |asset|
          stub_asset_manager_has_an_asset(asset.asset_manager_id, { deleted: false, file_url: asset.filename })
        end
      end

      test "it should include the attachment in the report" do
        assert_output(/^#{attachment.content_id}$/) { task.invoke }
      end
    end

    context "when asset is soft deleted from asset manager" do
      before do
        attachment.attachment_data.assets.each do |asset|
          stub_asset_manager_has_an_asset(asset.asset_manager_id, { deleted: true, file_url: asset.filename })
        end
      end

      test "it should not include the attachment in the report" do
        refute_output(/#{attachment.content_id}/) { task.invoke }
      end
    end

    context "when asset is hard deleted from asset manager" do
      before do
        attachment.attachment_data.assets.each do |asset|
          stub_asset_manager_does_not_have_an_asset(asset.asset_manager_id)
        end
      end

      test "it should not include the attachment in the report" do
        refute_output(/#{attachment.content_id}/) { task.invoke }
      end
    end
  end

  context "for an asset attached only to a draft edition" do
    let!(:edition) { create(:draft_publication) }
    let!(:attachment) { create(:file_attachment_with_asset, attachable: edition) }

    context "when asset is not deleted from asset manager" do
      before do
        attachment.attachment_data.assets.each do |asset|
          stub_asset_manager_has_an_asset(asset.asset_manager_id, { deleted: false, file_url: asset.filename })
        end
      end

      test "it should not include the attachment in the report" do
        refute_output(/#{attachment.content_id}/) { task.invoke }
      end
    end

    context "when asset is deleted from asset manager" do
      before do
        attachment.attachment_data.assets.each do |asset|
          stub_asset_manager_has_an_asset(asset.asset_manager_id, { deleted: true, file_url: asset.filename })
        end
      end

      test "it should not include the attachment in the report" do
        refute_output(/#{attachment.content_id}/) { task.invoke }
      end
    end
  end

  context "for an asset attached only to a published edition" do
    let!(:edition) { create(:published_publication) }
    let!(:attachment) { create(:file_attachment_with_asset, attachable: edition) }

    context "when asset is not deleted from asset manager" do
      before do
        attachment.attachment_data.assets.each do |asset|
          stub_asset_manager_has_an_asset(asset.asset_manager_id, { deleted: false, file_url: asset.filename })
        end
      end

      test "it should not include the attachment in the report" do
        refute_output(/#{attachment.content_id}/) { task.invoke }
      end
    end

    context "when asset is deleted from asset manager" do
      before do
        attachment.attachment_data.assets.each do |asset|
          stub_asset_manager_has_an_asset(asset.asset_manager_id, { deleted: true, file_url: asset.filename })
        end
      end

      test "it should not include the attachment in the report" do
        refute_output(/#{attachment.attachment_data.assets.first.filename},#{edition.public_url},#{edition.state}/) { task.invoke }
      end
    end
  end

  context "for an asset attached to both published and superseded editions" do
    let!(:attachment) { create(:file_attachment_with_asset) }
    let!(:edition_1) { create(:superseded_publication, :with_alternative_format_provider, attachments: [attachment]) }
    let!(:edition_2) { create(:published_publication, :with_alternative_format_provider, attachments: [attachment]) }

    context "when asset is not deleted from asset manager" do
      before do
        attachment.attachment_data.assets.each do |asset|
          stub_asset_manager_has_an_asset(asset.asset_manager_id, { deleted: false, file_url: asset.filename })
        end
      end

      test "it should not include the attachment in the report" do
        refute_output(/#{attachment.content_id}/) { task.invoke }
      end
    end

    context "when asset is deleted from asset manager" do
      before do
        attachment.attachment_data.assets.each do |asset|
          stub_asset_manager_has_an_asset(asset.asset_manager_id, { deleted: true, file_url: asset.filename })
        end
      end

      test "it should not include the attachment in the report" do
        refute_output(/#{attachment.content_id}/) { task.invoke }
      end
    end
  end

  context "for an asset attached only to something that is not an edition" do
    let(:attachment) { create(:file_attachment_with_asset, attachable: create(:double)) }

    test "it should include no output in the report" do
      assert_output("") { task.invoke }
    end
  end
end
