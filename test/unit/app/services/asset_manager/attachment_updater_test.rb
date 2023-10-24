require "test_helper"

class AssetManager::AttachmentUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManager::AttachmentUpdater do
    context "when the attachment's attachable is a draft" do
      let(:edition) { create(:draft_news_article) }
      let(:attachment) { create(:file_attachment, attachable: edition) }

      it "marks corresponding assets as draft" do
        expected_attribute_hash = {
          "draft" => true,
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, draft_status: true)
      end

      it "sets parent_document_url for all assets" do
        expected_attribute_hash = { "parent_document_url" => edition.public_url(draft: true) }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, link_header: true)
      end

      it "updates all assets to have an empty access_limited array when the draft is not access limited" do
        expected_attribute_hash = {
          "access_limited_organisation_ids" => [],
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, access_limited: true)
      end
    end

    context "when the attachment's attachable is a draft and is access limited" do
      it "updates the access limited state of all assets" do
        edition = create(:draft_news_article, :access_limited)
        attachment = create(:file_attachment, attachable: edition)

        expected_attribute_hash = {
          "access_limited_organisation_ids" => edition.organisations.map(&:content_id),
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, access_limited: true)
      end
    end

    context "when attachment belongs to a scheduled edition" do
      let(:scheduled_edition) { create(:scheduled_edition) }
      let(:attachment) { create(:file_attachment, attachable: scheduled_edition) }

      it "sets parent_document_url for attachment using draft hostname" do
        expected_attribute_hash = { "parent_document_url" => scheduled_edition.public_url(draft: true) }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, link_header: true)
      end
    end

    context "when attachment belongs to a submitted edition" do
      let(:submitted_edition) { create(:submitted_edition) }
      let(:attachment) { create(:file_attachment, attachable: submitted_edition) }

      it "sets parent_document_url for attachment using draft hostname" do
        expected_attribute_hash = { "parent_document_url" => submitted_edition.public_url(draft: true) }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, link_header: true)
      end
    end

    context "when attachment belongs to a rejected edition" do
      let(:rejected_edition) { create(:rejected_edition) }
      let(:attachment) { create(:file_attachment, attachable: rejected_edition) }

      it "sets parent_document_url for attachment using draft hostname" do
        expected_attribute_hash = { "parent_document_url" => rejected_edition.public_url(draft: true) }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, link_header: true)
      end
    end

    context "when attachment's attachable is published" do
      let(:edition) { create(:published_news_article) }
      let(:attachment) { create(:file_attachment, attachable: edition) }

      it "marks corresponding assets as not draft" do
        expected_attribute_hash = {
          "draft" => false,
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, draft_status: true)
      end

      it "sets parent_document_url for all assets" do
        expected_attribute_hash = {
          "parent_document_url" => edition.public_url,
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, link_header: true)
      end

      it "resets the redirect URL for all assets" do
        expected_attribute_hash = {
          "redirect_url" => nil,
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, redirect_url: true)
      end

      it "does not update asset manager when the attachment data has not been replaced" do
        AssetManager::AssetUpdater.expects(:call).never

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, replacement_id: true)
      end
    end

    context "when the attachment data has been replaced" do
      let(:edition) { create(:draft_news_article) }
      let(:attachment) { create(:file_attachment, attachable: edition) }

      context "and the attachment has been replaced with an attachment that has the same number of assets" do
        it "it updates asset with matching replacement IDs based on asset variant" do
          replacement = AttachmentData.create!(file: File.open(fixture_path.join("whitepaper.pdf")))
          replacement_original_asset = Asset.new(asset_manager_id: "replacement_original_asset_manager_id", variant: Asset.variants[:original], filename: "whitepaper.pdf")
          replacement_thumbnail_asset = Asset.new(asset_manager_id: "replacement_thumbnail_asset_manager_id", variant: Asset.variants[:thumbnail], filename: "thumbnail_whitepaper.pdf.png")
          replacement.assets = [replacement_original_asset, replacement_thumbnail_asset]

          attachment.attachment_data.replace_with!(replacement)

          replacement_attributes = { "replacement_id" => replacement_original_asset.asset_manager_id }
          replacement_thumbnail_attributes = { "replacement_id" => replacement_thumbnail_asset.asset_manager_id }

          AssetManager::AssetUpdater.expects(:call)
                                    .with(attachment.attachment_data.assets.first.asset_manager_id, attachment.attachment_data, nil, replacement_attributes)
          AssetManager::AssetUpdater.expects(:call)
                                    .with(attachment.attachment_data.assets.last.asset_manager_id, attachment.attachment_data, nil, replacement_thumbnail_attributes)

          AssetManager::AttachmentUpdater.call(attachment.attachment_data, replacement_id: true)
        end
      end

      context "and the attachment has been replaced with an attachment that has a different number of assets" do
        it "updates all assets (of attachment to be updated) with original asset ID of replacement attachment" do
          replacement = AttachmentData.create!(file: File.open(fixture_path.join("whitepaper.pdf")))
          replacement_original_asset = Asset.new(asset_manager_id: "replacement_original_asset_manager_id", variant: Asset.variants[:original], filename: "whitepaper.pdf")
          replacement.assets = [replacement_original_asset]

          attachment.attachment_data.replace_with!(replacement)

          replacement_attributes = { "replacement_id" => replacement_original_asset.asset_manager_id }

          AssetManager::AssetUpdater.expects(:call).with(attachment.attachment_data.assets.first.asset_manager_id, attachment.attachment_data, nil, replacement_attributes)
          AssetManager::AssetUpdater.expects(:call).with(attachment.attachment_data.assets.last.asset_manager_id, attachment.attachment_data, nil, replacement_attributes)

          AssetManager::AttachmentUpdater.call(attachment.attachment_data, replacement_id: true)
        end
      end

      context "and the attachment has been replaced with an attachment that has no assets" do
        it "does not update asset manager" do
          replacement = AttachmentData.create!(file: File.open(fixture_path.join("whitepaper.pdf")))
          replacement.assets = []

          attachment.attachment_data.replace_with!(replacement)

          AssetManager::AssetUpdater.expects(:call).never

          AssetManager::AttachmentUpdater.call(attachment.attachment_data, replacement_id: true)
        end
      end
    end

    context "when attachment's attachable is published" do
      let(:edition) { create(:published_news_article) }
      let(:attachment) { create(:file_attachment, attachable: edition) }

      it "marks corresponding assets as not draft" do
        expected_attribute_hash = {
          "draft" => false,
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, draft_status: true)
      end

      it "sets parent_document_url for all assets" do
        expected_attribute_hash = {
          "parent_document_url" => edition.public_url,
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, link_header: true)
      end

      it "resets the redirect URL for all assets" do
        expected_attribute_hash = {
          "redirect_url" => nil,
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, redirect_url: true)
      end

      context "and the attachment has been deleted" do
        it "does not update the asset" do
          attachment.delete

          AssetManager::AssetUpdater.expects(:call).never

          AssetManager::AttachmentUpdater.call(attachment.attachment_data, redirect_url: true, draft_status: true)
        end
      end
    end

    context "when the attachment's attachable is unpublished" do
      it "updates redirect URL for all assets" do
        edition = create(:unpublished_edition)
        attachment = create(:file_attachment, attachable: edition)

        expected_attribute_hash = {
          "redirect_url" => edition.unpublishing.document_url,
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, attachment.attachment_data, nil, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data, redirect_url: true)
      end
    end
  end
end
