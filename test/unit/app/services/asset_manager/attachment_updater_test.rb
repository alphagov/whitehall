require "test_helper"

class AssetManager::AttachmentUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManager::AttachmentUpdater do
    context "when the attachment's attachable is a draft" do
      let(:edition) { create(:draft_publication) }
      let(:attachment) { create(:file_attachment, attachable: edition, attachment_data: create(:attachment_data, attachable: edition)) }

      it "sets the expected attributes" do
        expected_attribute_hash = {
          "draft" => true,
          "access_limited_organisation_ids" => [],
          "access_limited_user_ids" => [],
          "parent_document_url" => edition.public_url(draft: true),
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data)
      end

      context "and the attachment has been replaced" do
        it "ensures replaced attachment data is still accessible for the publicly visible edition" do
          replacement = create(:attachment_data, attachable: edition)
          replaced_attachment_data = attachment.attachment_data

          attachment.attachment_data.replace_with!(replacement)
          attachment.attachment_data = replacement
          attachment.save!

          replaced_attachment_data.reload

          expected_attribute_hash = {
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
            "draft" => false,
          }

          replaced_attachment_data.assets.each do |asset|
            AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
          end

          AssetManager::AttachmentUpdater.call(replaced_attachment_data)
        end
      end
    end

    context "when the attachment's attachable is a draft and is access limited" do
      it "sets the expected attributes for all assets" do
        edition = create(:draft_publication, :access_limited)
        attachment = create(:file_attachment, attachable: edition, attachment_data: create(:attachment_data, attachable: edition))

        expected_attribute_hash = {
          "draft" => true,
          "parent_document_url" => edition.public_url(draft: true),
          "access_limited_organisation_ids" => edition.organisations.map(&:content_id),
          "access_limited_user_ids" => [],
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data)
      end
    end

    context "when the attachment's attachable is a draft and is access limited to individuals" do
      it "sends the individual user uids for all assets" do
        user = create(:user)
        edition = create(:draft_publication, access_limiting: "individuals", access_limiting_individual_emails: user.email)
        attachment = create(:file_attachment, attachable: edition, attachment_data: create(:attachment_data, attachable: edition))

        expected_attribute_hash = {
          "draft" => true,
          "parent_document_url" => edition.public_url(draft: true),
          "access_limited_organisation_ids" => [],
          "access_limited_user_ids" => [user.uid],
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data)
      end
    end

    context "when attachment belongs to a scheduled edition" do
      let(:scheduled_edition) { create(:scheduled_edition) }
      let(:attachment) { create(:file_attachment, attachable: scheduled_edition, attachment_data: create(:attachment_data, attachable: scheduled_edition)) }

      it "sets the expected attributes for all assets" do
        expected_attribute_hash = {
          "draft" => true,
          "parent_document_url" => scheduled_edition.public_url(draft: true),
          "access_limited_organisation_ids" => [],
          "access_limited_user_ids" => [],
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data)
      end
    end

    context "when attachment belongs to a submitted edition" do
      let(:submitted_edition) { create(:submitted_edition) }
      let(:attachment) { create(:file_attachment, attachable: submitted_edition, attachment_data: create(:attachment_data, attachable: submitted_edition)) }

      it "sets the expected attributes for all assets" do
        expected_attribute_hash = {
          "draft" => true,
          "parent_document_url" => submitted_edition.public_url(draft: true),
          "access_limited_organisation_ids" => [],
          "access_limited_user_ids" => [],
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data)
      end
    end

    context "when attachment belongs to a rejected edition" do
      let(:rejected_edition) { create(:rejected_edition) }
      let(:attachment) { create(:file_attachment, attachable: rejected_edition, attachment_data: create(:attachment_data, attachable: rejected_edition)) }

      it "sets the expected attributes for all assets" do
        expected_attribute_hash = {
          "draft" => true,
          "parent_document_url" => rejected_edition.public_url(draft: true),
          "access_limited_organisation_ids" => [],
          "access_limited_user_ids" => [],
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data)
      end
    end

    context "when attachment's attachable is published" do
      let(:edition) { create(:published_publication) }
      let(:attachment) { create(:file_attachment, attachable: edition, attachment_data: create(:attachment_data, attachable: edition)) }

      it "sets the expected attributes for a published attachable" do
        expected_attribute_hash = {
          "draft" => false,
          "parent_document_url" => edition.public_url,
          "access_limited_organisation_ids" => [],
          "access_limited_user_ids" => [],
        }

        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data)
      end
    end

    context "when attachment's attachable is unpublished" do
      let(:edition) { create(:unpublished_publication, :with_file_attachment) }
      let(:attachment) { edition.attachments.first }

      it "sets the expected attributes for an unpublished attachable" do
        expected_attribute_hash = {
          "draft" => false,
          "parent_document_url" => nil,
          "access_limited_organisation_ids" => [],
          "access_limited_user_ids" => [],
        }
        attachment.attachment_data.assets.each do |asset|
          AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
        end

        AssetManager::AttachmentUpdater.call(attachment.attachment_data)
      end

      context "when attachment's attachable is redrafted from unpublished" do
        # This is a characterisation test - ideally the behaviour would allow for updates.
        # When redrafting from unpublished, the asset must stay live with a redirect url on it, to serve the "live" (unpublished) edition.
        # That means that it is not possible to preview the asset in draft.
        # It also means we cannot update the `parent_document_url` to draft, as this would invalidate an AssetManager rule
        # where the draft state of the asset and the parent URL must match.

        let(:edition) { create(:unpublished_publication, :with_file_attachment) }
        let(:draft_edition) { edition.create_draft(create(:user)) }
        let(:attachment) { draft_edition.attachments.first }
        let(:asset_manager_id) { attachment.attachment_data.assets.first.asset_manager_id }

        before do
          Services.asset_manager.expects(:asset).with(asset_manager_id).returns("id" => asset_manager_id, "parent_document_url" => nil, "draft" => false)
          Services.asset_manager.expects(:update_asset).with(asset_manager_id, { "parent_document_url" => draft_edition.public_url(draft: true), "draft" => false, "access_limited_organisation_ids" => [], "access_limited_user_ids" => [] }).raises(GdsApi::HTTPUnprocessableEntity, "Parent document url must be a public GOV.UK URL")
        end

        it "attempts to update, and does not raise" do
          AssetManager::AttachmentUpdater.call(attachment.attachment_data)
        end
      end
    end

    context "when the attachment data has been replaced" do
      let(:edition) { create(:draft_publication) }
      let(:attachment) { create(:file_attachment, attachable: edition, attachment_data: create(:attachment_data, attachable: edition)) }

      it "it updates attachment asset with matching variant replacement asset ID" do
        replacement = AttachmentData.create!(file: File.open(fixture_path.join("whitepaper.pdf")), attachable: edition)
        replacement_asset = Asset.new(asset_manager_id: "replacement_asset_manager_id", variant: Asset.variants[:original], filename: "whitepaper.pdf")
        replacement.assets << replacement_asset
        attachment.attachment_data.replace_with!(replacement)

        AssetManager::AssetUpdater.expects(:call)
                                  .with(attachment.attachment_data.assets.first.asset_manager_id, { "replacement_id" => replacement_asset.asset_manager_id })

        AssetManager::AttachmentUpdater.replace(attachment.attachment_data)
      end

      # This test technically only covers the scenario in which we have non-migrated variants.
      # We have not deleted the thumbnails, so the replacement logic previously written to cater
      # for replacing a pdf with a document, comes in handy to help replace thumbnails of documents
      # that were in draft/published, with the original of their replacement.
      context "and the replacement has fewer asset variants than the attachment" do
        it "updates all attachment's assets with the replacement's original variant asset ID" do
          deprecated_variant_asset = build(:asset, asset_manager_id: "some_variant_asset_manager_id", variant: "s630", filename: "whitepaper.pdf")
          attachment.attachment_data.assets << deprecated_variant_asset
          replacement = AttachmentData.create!(file: File.open(fixture_path.join("whitepaper.pdf")), attachable: edition)
          replacement_original_asset = Asset.new(asset_manager_id: "replacement_original_asset_manager_id", variant: Asset.variants[:original], filename: "whitepaper.pdf")
          replacement.assets << replacement_original_asset
          attachment.attachment_data.replace_with!(replacement)

          AssetManager::AssetUpdater.expects(:call).with("asset_manager_id", { "replacement_id" => replacement_original_asset.asset_manager_id })
          AssetManager::AssetUpdater.expects(:call).with(deprecated_variant_asset.asset_manager_id, { "replacement_id" => replacement_original_asset.asset_manager_id })

          AssetManager::AttachmentUpdater.replace(attachment.attachment_data)
        end
      end

      context "and the attachment has been replaced with an attachment that has no assets" do
        it "does not update asset manager" do
          replacement = AttachmentData.create!(file: File.open(fixture_path.join("whitepaper.pdf")), attachable: edition)
          replacement.assets = []

          attachment.attachment_data.replace_with!(replacement)

          AssetManager::AssetUpdater.expects(:call).never

          AssetManager::AttachmentUpdater.replace(attachment.attachment_data)
        end
      end
    end

    context "when the attachment belongs to a draft consultation's outcome" do
      let(:consultation) { create(:draft_consultation) }
      let(:outcome) { create(:consultation_outcome, :with_file_attachment, consultation:) }
      let(:attachment_data) { outcome.attachments.first.attachment_data }
      let(:asset_manager_id) { attachment_data.assets.first.asset_manager_id }

      it "sets the expected attributes" do
        AssetManager::AssetUpdater.expects(:call).with(
          asset_manager_id,
          {
            "draft" => true,
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
            "parent_document_url" => consultation.public_url(draft: true),
          },
        )

        AssetManager::AttachmentUpdater.call(attachment_data)
      end
    end

    context "when the attachment belongs to a published consultation's outcome" do
      let(:consultation) { create(:published_consultation) }
      let(:outcome) { create(:consultation_outcome, :with_file_attachment, consultation:) }
      let(:attachment_data) { outcome.attachments.first.attachment_data }
      let(:asset_manager_id) { attachment_data.assets.first.asset_manager_id }

      it "sets the expected attributes" do
        AssetManager::AssetUpdater.expects(:call).with(
          asset_manager_id,
          {
            "draft" => false,
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
            "parent_document_url" => consultation.public_url,
          },
        )

        AssetManager::AttachmentUpdater.call(attachment_data)
      end
    end

    context "when the attachment belongs to a policy group" do
      let(:policy_group) { create(:policy_group, :with_file_attachment) }
      let(:attachment_data) { policy_group.attachments.first.attachment_data }
      let(:asset_manager_id) { attachment_data.assets.first.asset_manager_id }

      it "sets the expected attributes" do
        AssetManager::AssetUpdater.expects(:call).with(
          asset_manager_id,
          {
            "draft" => false,
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
            "parent_document_url" => policy_group.public_url,
          },
        )

        AssetManager::AttachmentUpdater.call(attachment_data)
      end
    end
  end
end
