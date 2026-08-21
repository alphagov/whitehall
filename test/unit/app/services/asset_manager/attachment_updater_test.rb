require "test_helper"
require "attachment_test_helper"

class AssetManager::AttachmentUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  def it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
    attachment_data = attachment.send(asset_data_type.underscore.to_sym)

    attachment_data.assets.each do |asset|
      AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
    end

    AssetManager::AttachmentUpdater.call(attachment_data)
  end

  describe AssetManager::AttachmentUpdater do
    for_each_asset_data_type do |asset_data_type|
      context "when the attachment's attachable is a draft" do
        let(:edition) { create(:draft_publication) }
        let(:attachment_data) { build(asset_data_type.underscore.to_sym) }
        let(:attachment) { create_attachment(attachment_data:, edition:) }

        it "sets expected attributes" do
          expected_attribute_hash = {
            "draft" => true,
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
            "parent_document_url" => edition.public_url(draft: true),
          }

          it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
        end

        context "and the attachment has been replaced" do
          it "ensures replaced attachment data is still accessible for the publicly visible edition" do
            replacement = case asset_data_type
                          when "AttachmentData"
                            create(:attachment_data, attachable: edition)
                          when "ImageData"
                            create(:image_data)
                          end

            replaced_attachment_data = attachment.send(asset_data_type.underscore.to_sym)
            attachment_data.replace_with!(replacement)

            if asset_data_type == "AttachmentData"
              attachment.attachment_data = replacement
            elsif asset_data_type == "ImageData"
              replacement.images << attachment
            end

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

      context "when the attachment's attachable is a draft and is access limited to organisations" do
        it "sets the expected attributes for all assets" do
          edition = create(:draft_publication, :access_limited_by_organisations)
          attachment_data = build(asset_data_type.underscore.to_sym)
          attachment = create_attachment(attachment_data:, edition:)

          expected_attribute_hash = {
            "draft" => true,
            "parent_document_url" => edition.public_url(draft: true),
            "access_limited_organisation_ids" => edition.organisations.map(&:content_id),
            "access_limited_user_ids" => [],
          }

          it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
        end

        it "sets the expected asset attributes when the access_limiting_organisations_ui flag is on" do
          @feature_flags.switch!(:access_limiting_organisations_ui, true)

          organisation = create(:organisation)
          edition = create(
            :publication,
            access_limiting: "organisations",
            create_default_organisation: true,
            access_limiting_organisation_ids: [organisation.id],
          )
          attachment_data = build(asset_data_type.underscore.to_sym)
          attachment = create_attachment(attachment_data:, edition:)

          expected_attribute_hash = {
            "draft" => true,
            "parent_document_url" => edition.public_url(draft: true),
            "access_limited_organisation_ids" => [organisation.content_id],
            "access_limited_user_ids" => [],
          }

          it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
        end
      end

      context "when the attachment's attachable is a draft and is access limited to individuals" do
        it "sends the individual user uids for all assets when the access_limiting_individuals_ui flag is on" do
          @feature_flags.switch!(:access_limiting_individuals_ui, true)

          user = create(:user)
          edition = create(:draft_publication, access_limiting: "individuals", access_limiting_individual_emails: user.email)
          attachment_data = build(asset_data_type.underscore.to_sym)
          attachment = create_attachment(attachment_data:, edition:)

          expected_attribute_hash = {
            "draft" => true,
            "parent_document_url" => edition.public_url(draft: true),
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [user.uid],
          }

          it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
        end
      end

      context "when attachment belongs to a scheduled edition" do
        let(:scheduled_edition) { create(:scheduled_publication) }
        let(:attachment_data) { build(asset_data_type.underscore.to_sym) }
        let(:attachment) { create_attachment(attachment_data:, edition: scheduled_edition) }

        it "sets the expected attributes for all assets" do
          expected_attribute_hash = {
            "draft" => true,
            "parent_document_url" => scheduled_edition.public_url(draft: true),
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
          }

          it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
        end
      end

      context "when attachment belongs to a submitted edition" do
        let(:submitted_edition) { create(:submitted_publication) }
        let(:attachment_data) { build(asset_data_type.underscore.to_sym) }
        let(:attachment) { create_attachment(attachment_data:, edition: submitted_edition) }

        it "sets the expected attributes for all assets" do
          expected_attribute_hash = {
            "draft" => true,
            "parent_document_url" => submitted_edition.public_url(draft: true),
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
          }

          it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
        end
      end

      context "when attachment belongs to a rejected edition" do
        let(:rejected_edition) { create(:rejected_publication) }
        let(:attachment_data) { build(asset_data_type.underscore.to_sym) }
        let(:attachment) { create_attachment(attachment_data:, edition: rejected_edition) }

        it "sets the expected attributes for all assets" do
          expected_attribute_hash = {
            "draft" => true,
            "parent_document_url" => rejected_edition.public_url(draft: true),
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
          }

          it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
        end
      end

      context "when attachment's attachable is published" do
        let(:edition) { create(:published_publication) }
        let(:attachment_data) { build(asset_data_type.underscore.to_sym) }
        let(:attachment) { create_attachment(attachment_data:, edition:) }

        it "sets the expected attributes for a published attachable" do
          expected_attribute_hash = {
            "draft" => false,
            "parent_document_url" => edition.public_url,
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
          }

          it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
        end
      end

      context "when attachment's attachable is unpublished" do
        let(:edition) { create(:unpublished_publication) }
        let(:attachment_data) { build(asset_data_type.underscore.to_sym) }
        let(:attachment) { create_attachment(attachment_data:, edition:) }

        it "sets the expected attributes for an unpublished attachable" do
          expected_attribute_hash = {
            "draft" => false,
            "parent_document_url" => nil,
            "access_limited_organisation_ids" => [],
            "access_limited_user_ids" => [],
          }

          it_sets_expected_attributes(expected_attribute_hash, attachment, asset_data_type)
        end
      end

      context "when attachment's attachable is redrafted from unpublished" do
        # This is a characterisation test - ideally the behaviour would allow for updates.
        # When redrafting from unpublished, the asset must stay live with a redirect url on it, to serve the "live" (unpublished) edition.
        # That means that it is not possible to preview the asset in draft.
        # It also means we cannot update the `parent_document_url` to draft, as this would invalidate an AssetManager rule
        # where the draft state of the asset and the parent URL must match.
        let(:edition) do
          if asset_data_type == "AttachmentData"
            create(:unpublished_publication, :with_file_attachment)
          else
            create(:unpublished_publication, :with_image)
          end
        end
        let(:draft_edition) { edition.create_draft(create(:user)) }
        let(:attachment) do
          if asset_data_type == "AttachmentData"
            draft_edition.attachments.first
          elsif asset_data_type == "ImageData"
            draft_edition.images.first
          end
        end

        before do
          attachment.send(asset_data_type.underscore.to_sym).assets.each do |asset|
            asset_manager_id = asset.asset_manager_id
            Services.asset_manager.expects(:asset).with(asset_manager_id).returns("id" => asset_manager_id, "parent_document_url" => nil, "draft" => false)
            Services.asset_manager.expects(:update_asset).with(asset_manager_id, { "parent_document_url" => draft_edition.public_url(draft: true), "draft" => false, "access_limited_organisation_ids" => [], "access_limited_user_ids" => [] }).raises(GdsApi::HTTPUnprocessableEntity, "Parent document url must be a public GOV.UK URL")
          end
        end

        it "attempts to update, and does not raise" do
          AssetManager::AttachmentUpdater.call(attachment.send(asset_data_type.underscore.to_sym))
        end
      end

      context "when the attachment data has been replaced" do
        let(:edition) { create(:draft_publication) }
        let(:attachment) { create_attachment(attachment_data: build(asset_data_type.underscore.to_sym), edition:) }
        let(:filename) do
          case asset_data_type
          when "AttachmentData"
            "whitepaper.pdf"
          when "ImageData"
            "big-cheese.960x640.jpg"
          end
        end

        it "it updates attachment asset with matching variant replacement asset ID" do
          replacement = case asset_data_type
                        when "AttachmentData"
                          AttachmentData.create!(file: File.open(fixture_path.join(filename)), attachable: edition)
                        when "ImageData"
                          ImageData.create!(image_kind: "default", file: File.open(fixture_path.join(filename)))
                        end

          replacement_asset = case asset_data_type
                              when "AttachmentData"
                                Asset.new(asset_manager_id: "replacement_asset_manager_id", variant: Asset.variants[:original], filename:)
                              when "ImageData"
                                Asset.new(asset_manager_id: "replacement_original_asset_manager_id", variant: Asset.variants[:original], filename:)
                              end

          replacement.assets << replacement_asset
          attachment.send(asset_data_type.underscore.to_sym).replace_with!(replacement)

          attachment.send(asset_data_type.underscore.to_sym).assets.each do |asset|
            asset_manager_id = asset.asset_manager_id

            AssetManager::AssetUpdater.expects(:call)
                                      .with(asset_manager_id, { "replacement_id" => replacement_asset.asset_manager_id })
          end

          AssetManager::AttachmentUpdater.replace(attachment.send(asset_data_type.underscore.to_sym))
        end

        # This test technically only covers the scenario in which we have non-migrated variants.
        # We have not deleted the thumbnails, so the replacement logic previously written to cater
        # for replacing a pdf with a document, comes in handy to help replace thumbnails of documents
        # that were in draft/published, with the original of their replacement.
        context "and the replacement has fewer asset variants than the attachment" do
          it "updates all attachment's assets with the replacement's original variant asset ID" do
            deprecated_variant_asset = build(:asset, asset_manager_id: "some_variant_asset_manager_id", variant: "s630", filename:)
            attachment.send(asset_data_type.underscore.to_sym).assets << deprecated_variant_asset

            replacement = case asset_data_type
                          when "AttachmentData"
                            AttachmentData.create!(file: File.open(fixture_path.join(filename)), attachable: edition)
                          when "ImageData"
                            ImageData.create!(image_kind: "default", file: File.open(fixture_path.join(filename)))
                          end

            replacement_original_asset = Asset.new(asset_manager_id: "replacement_original_asset_manager_id", variant: Asset.variants[:original], filename:)
            replacement.assets << replacement_original_asset
            attachment.send(asset_data_type.underscore.to_sym).replace_with!(replacement)

            attachment.send(asset_data_type.underscore.to_sym).assets.each do |asset|
              asset_manager_id = asset.asset_manager_id

              AssetManager::AssetUpdater.expects(:call).with(asset_manager_id, { "replacement_id" => replacement_original_asset.asset_manager_id })
            end

            AssetManager::AttachmentUpdater.replace(attachment.send(asset_data_type.underscore.to_sym))
          end
        end

        context "and the attachment has been replaced with an attachment that has no assets" do
          it "does not update asset manager" do
            replacement = case asset_data_type
                          when "AttachmentData"
                            AttachmentData.create!(file: File.open(fixture_path.join(filename)), attachable: edition)
                          when "ImageData"
                            ImageData.create!(image_kind: "default", file: File.open(fixture_path.join(filename)))
                          end
            replacement.assets = []

            attachment.send(asset_data_type.underscore.to_sym).replace_with!(replacement)

            AssetManager::AssetUpdater.expects(:call).never

            AssetManager::AttachmentUpdater.replace(attachment.send(asset_data_type.underscore.to_sym))
          end
        end
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

    it "sets access limiting to organisations when the access_limiting_organisations_ui flag is on" do
      @feature_flags.switch!(:access_limiting_organisations_ui, true)

      organisation = create(:organisation)
      consultation = create(
        :draft_consultation,
        access_limiting: "organisations",
        create_default_organisation: true,
        access_limiting_organisation_ids: [organisation.id],
      )
      outcome = create(:consultation_outcome, consultation:)
      attachment = create(:file_attachment, attachable: outcome, attachment_data: create(:attachment_data, attachable: outcome))
      attachment_data = attachment.attachment_data
      asset_manager_id = attachment_data.assets.first.asset_manager_id

      AssetManager::AssetUpdater.expects(:call).with(
        asset_manager_id,
        {
          "draft" => true,
          "access_limited_organisation_ids" => [organisation.content_id],
          "access_limited_user_ids" => [],
          "parent_document_url" => consultation.public_url(draft: true),
        },
      )

      AssetManager::AttachmentUpdater.call(attachment_data)
    end

    it "sets access limiting to individuals when the access_limiting_individuals_ui flag is on" do
      @feature_flags.switch!(:access_limiting_individuals_ui, true)

      user = create(:user)
      consultation = create(
        :draft_consultation,
        create_default_organisation: true,
        access_limiting: "individuals",
        access_limiting_individual_emails: user.email,
      )
      outcome = create(:consultation_outcome, consultation:)
      attachment = create(:file_attachment, attachable: outcome, attachment_data: create(:attachment_data, attachable: outcome))
      attachment_data = attachment.attachment_data
      asset_manager_id = attachment_data.assets.first.asset_manager_id

      AssetManager::AssetUpdater.expects(:call).with(
        asset_manager_id,
        {
          "draft" => true,
          "access_limited_organisation_ids" => [],
          "access_limited_user_ids" => [user.uid],
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
