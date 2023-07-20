require "test_helper"

class AssetManager::AttachmentUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManager::AttachmentUpdater do
    let(:updater) { AssetManager::AttachmentUpdater }
    let(:attachment_data) { attachment.attachment_data }

    context "AttachmentData has no assets" do
      let(:file) { File.open(fixture_path.join("sample.rtf")) }
      let(:attachment) { FactoryBot.create(:file_attachment, file:) }

      it "groups updates together" do
        AssetManager::AssetUpdater.expects(:call).once

        updater.call(attachment_data, redirect_url: true, draft_status: true)
      end

      context "when the attachment has been deleted" do
        before do
          attachment.delete
        end

        it "does not update the asset" do
          AssetManager::AssetUpdater.expects(:call).never

          updater.call(attachment_data, redirect_url: true, draft_status: true)
        end
      end
    end

    context "AttachmentData has assets" do
      let(:update_service) { mock("asset-manager-update-asset-worker") }
      let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }
      let(:original) { Asset.variants[:original] }
      let(:thumbnail) { Asset.variants[:thumbnail] }
      let(:original_asset) { Asset.new(asset_manager_id: "original_asset_manager_id", variant: original) }
      let(:thumbnail_asset) { Asset.new(asset_manager_id: "thumbnail_asset_manager_id", variant: thumbnail) }

      around do |test|
        AssetManager.stub_const(:AssetUpdater, update_service) do
          test.call
        end
      end

      before do
        attachment_data.assets = [original_asset, thumbnail_asset]
      end

      context "when the attachment has been deleted" do
        before do
          attachment.delete
        end

        it "does not update the asset" do
          AssetManager::AssetUpdater.expects(:call).never

          updater.call(attachment_data, redirect_url: true, draft_status: true)
        end
      end

      describe "access limited updates" do
        context "when attachment's attachable is access limited" do
          before do
            access_limited_object = stub("access-limited-object")
            AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(%w[user-uid])

            attachment_data.stubs(:access_limited?).returns(true)
            attachment_data.stubs(:access_limited_object).returns(access_limited_object)
          end

          it "updates the access limited state of all assets" do
            update_service.expects(:call)
                          .with(original_asset.asset_manager_id, attachment_data, nil, { "access_limited" => %w[user-uid] })
            update_service.expects(:call)
                          .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "access_limited" => %w[user-uid] })

            updater.call(attachment_data, access_limited: true)
          end
        end

        context "when attachment's attachable is not access limited" do
          before do
            attachment_data.stubs(:access_limited?).returns(false)
          end

          it "updates all assets to have an empty access_limited array" do
            update_service.expects(:call)
                          .with(original_asset.asset_manager_id, attachment_data, nil, { "access_limited" => [] })
            update_service.expects(:call)
                          .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "access_limited" => [] })

            updater.call(attachment_data, access_limited: true)
          end
        end
      end

      describe "draft status updates" do
        let(:draft) { true }
        let(:unpublished) { false }
        let(:replaced) { false }

        before do
          attachment_data.stubs(:draft?).returns(draft)
          attachment_data.stubs(:unpublished?).returns(unpublished)
          attachment_data.stubs(:replaced?).returns(replaced)
        end

        it "marks corresponding assets as draft" do
          update_service.expects(:call)
                        .with(original_asset.asset_manager_id, attachment_data, nil, { "draft" => true })
          update_service.expects(:call)
                        .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "draft" => true })

          updater.call(attachment_data, draft_status: true)
        end

        context "and attachment is not draft" do
          let(:draft) { false }

          it "marks corresponding assets as not draft" do
            update_service.expects(:call)
                          .with(original_asset.asset_manager_id, attachment_data, nil, { "draft" => false })
            update_service.expects(:call)
                          .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "draft" => false })

            updater.call(attachment_data, draft_status: true)
          end
        end

        context "and attachment is unpublished" do
          let(:unpublished) { true }

          it "marks corresponding assets as not draft even though attachment is draft" do
            attachment_data.update!(present_at_unpublish: true)
            update_service.expects(:call)
                          .with(original_asset.asset_manager_id, attachment_data, nil, { "draft" => false })
            update_service.expects(:call)
                          .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "draft" => false })

            updater.call(attachment_data, draft_status: true)
          end
        end

        context "and attachment is replaced" do
          let(:replaced) { true }

          it "marks corresponding assets as not draft even though attachment is draft" do
            update_service.expects(:call)
                          .with(original_asset.asset_manager_id, attachment_data, nil, { "draft" => false })
            update_service.expects(:call)
                          .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "draft" => false })

            updater.call(attachment_data, draft_status: true)
          end
        end
      end

      describe "link header updates" do
        let(:edition) { FactoryBot.create(:published_edition) }
        let(:parent_document_url) { edition.public_url }
        let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf, attachable: edition) }

        context "when attachment doesn't belong to an edition" do
          let(:attachment) { FactoryBot.create(:file_attachment) }

          it "does not update status of any assets" do
            update_service.expects(:call).never

            updater.call(attachment_data, link_header: true)
          end
        end

        context "when attachment belongs to a draft edition" do
          let(:draft_edition) { FactoryBot.create(:draft_edition) }
          let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf, attachable: draft_edition) }
          let(:parent_document_url) { draft_edition.public_url(draft: true) }

          it "sets parent_document_url for attachment using draft hostname" do
            update_service.expects(:call)
                          .with(original_asset.asset_manager_id, attachment_data, nil, { "parent_document_url" => parent_document_url })
            update_service.expects(:call)
                          .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "parent_document_url" => parent_document_url })

            updater.call(attachment_data, link_header: true)
          end
        end

        context "when edition is published" do
          it "sets parent_document_url for all assets" do
            update_service.expects(:call)
                          .with(original_asset.asset_manager_id, attachment_data, nil, { "parent_document_url" => parent_document_url })
            update_service.expects(:call)
                          .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "parent_document_url" => parent_document_url })

            updater.call(attachment_data, link_header: true)
          end
        end
      end

      describe "redirect url updates" do
        let(:unpublished_edition) { FactoryBot.create(:unpublished_edition) }
        let(:redirect_url) { unpublished_edition.public_url }
        let(:unpublished) { true }

        before do
          attachment_data.stubs(:unpublished?).returns(unpublished)
          attachment_data.stubs(:present_at_unpublish?).returns(true)
          attachment_data.stubs(:unpublished_edition).returns(unpublished_edition)
        end

        it "updates redirect URL for all assets" do
          update_service.expects(:call)
                        .with(original_asset.asset_manager_id, attachment_data, nil, { "redirect_url" => redirect_url })
          update_service.expects(:call)
                        .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "redirect_url" => redirect_url })

          updater.call(attachment_data, redirect_url: true)
        end

        context "and attachment is not unpublished" do
          let(:unpublished) { false }
          let(:unpublished_edition) { nil }

          it "resets redirect URL for all assets" do
            update_service.expects(:call)
                          .with(original_asset.asset_manager_id, attachment_data, nil, { "redirect_url" => nil })
            update_service.expects(:call)
                          .with(thumbnail_asset.asset_manager_id, attachment_data, nil, { "redirect_url" => nil })

            updater.call(attachment_data, redirect_url: true)
          end
        end
      end

      describe "replacement ID updates" do
        context "when attachment does not have a replacement" do
          let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
          let(:attachment_data) { AttachmentData.create!(file: sample_rtf) }

          it "does not update asset manager" do
            attachment_data.assets.create!(asset_manager_id: "asset_manager_id", variant: original)
            update_service.expects(:call).never

            updater.call(attachment_data, replacement_id: true)
          end
        end

        context "when attachment data being updated has multiple assets" do
          let(:whitepaper_pdf) { File.open(fixture_path.join("whitepaper.pdf")) }
          let(:replacement) { AttachmentData.create!(file: whitepaper_pdf) }
          let(:replacement_attributes) { { "replacement_id" => replacement_original_asset.asset_manager_id } }
          let(:replacement_thumbnail_attributes) { { "replacement_id" => replacement_thumbnail_asset.asset_manager_id } }
          let(:replacement_original_asset) { Asset.new(asset_manager_id: "replacement_original_asset_manager_id", variant: original) }
          let(:replacement_thumbnail_asset) { Asset.new(asset_manager_id: "replacement_thumbnail_asset_manager_id", variant: thumbnail) }

          before do
            attachment_data.replaced_by = replacement
          end

          it "and replacement has multiple assets - updates with matching replacement IDs based on asset variant" do
            replacement.assets = [replacement_original_asset, replacement_thumbnail_asset]

            update_service.expects(:call)
                          .with(original_asset.asset_manager_id, attachment_data, nil, replacement_attributes)
            update_service.expects(:call)
                          .with(thumbnail_asset.asset_manager_id, attachment_data, nil, replacement_thumbnail_attributes)

            updater.call(attachment_data, replacement_id: true)
          end

          context "but replacement has one asset" do
            let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
            let(:replacement) { AttachmentData.create!(file: sample_rtf) }

            it "updates all assets (of attachment to be updated) with original asset ID of replacement attachment" do
              replacement.assets = [replacement_original_asset]

              update_service.expects(:call)
                            .with(original_asset.asset_manager_id, attachment_data, nil, replacement_attributes)
              update_service.expects(:call)
                            .with(thumbnail_asset.asset_manager_id, attachment_data, nil, replacement_attributes)

              updater.call(attachment_data, replacement_id: true)
            end
          end
        end

        context "when attachment is not synced with asset manager" do
          let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
          let(:sample_docx) { File.open(fixture_path.join("sample.docx")) }
          let(:attachment_data) { AttachmentData.create!(file: sample_rtf, replaced_by: replacement) }
          let(:replacement) { AttachmentData.create!(file: sample_docx) }

          it "raises a AssetNotFound error" do
            attachment_data.assets.create!(asset_manager_id: "asset_manager_id", variant: original)
            replacement.assets.create!(asset_manager_id: "replacement_asset_manager_id", variant: original)

            update_service.expects(:call)
                          .raises(AssetManager::ServiceHelper::AssetNotFound.new("asset not found"))

            assert_raises(AssetManager::ServiceHelper::AssetNotFound) do
              updater.call(attachment_data, replacement_id: true)
            end
          end
        end
      end
    end
  end
end
