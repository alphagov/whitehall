require "test_helper"

class AssetManagerIntegrationTest
  class CreatingAFileAttachment < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "sample.docx"
      @edition = create(:draft_publication)
      @attachment = FactoryBot.build(:file_attachment_with_no_assets, file: file_fixture(@filename), attachable: @edition)
      @asset_manager_response = { "id" => "http://asset-manager/assets/asset_manager_id", "name" => @filename }
      Services.asset_manager.stubs(:asset).returns(@asset_manager_response)
    end

    test "sends the attachment to Asset Manager" do
      Services.asset_manager.expects(:create_asset).with { |args|
        args[:file].path =~ /#{@filename}/
      }.returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @attachment.save!
      end
    end

    test "marks the attachment as draft in Asset Manager" do
      Services.asset_manager.expects(:create_asset)
              .with(has_entry(draft: true))
              .returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @attachment.save!
      end
    end

    test "sends the user ids of authorised users to Asset Manager" do
      organisation = FactoryBot.create(:organisation)
      consultation = FactoryBot.create(:consultation, access_limiting: "organisations", access_limiting_organisation_ids: [organisation.id], organisations: [organisation])
      @attachment.attachable = consultation
      @attachment.attachment_data.attachable = consultation
      @attachment.save!

      Services.asset_manager.expects(:create_asset).with(has_entry(access_limited_organisation_ids: [organisation.content_id]))
              .returns(@asset_manager_response)

      AssetManagerCreateAssetJob.drain
    end
  end

  class CreatingAnImage < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @edition = create(:draft_publication)
      @attachment = FactoryBot.build(:image_with_no_assets, edition: @edition)
      @attachment.image_data.images << @attachment
      @asset_manager_response = { "id" => "http://asset-manager/assets/asset_manager_id", "name" => @filename }
      Services.asset_manager.stubs(:asset).returns(@asset_manager_response)
    end

    test "sends the attachment to Asset Manager" do
      Services.asset_manager.expects(:create_asset).at_least_once.with { |args|
        args[:file].path =~ /#{@filename}/
      }.returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @attachment.save!
      end
    end

    test "marks the attachment as draft in Asset Manager" do
      Services.asset_manager.expects(:create_asset)
              .at_least_once
              .with(has_entry(draft: true))
              .returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @attachment.save!
      end
    end
  end

  class CreatingAnAuthorisedImage < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @edition = create(:draft_consultation)
      @edition.access_limiting = "organisations"
      @edition.access_limiting_organisation_ids = @edition.organisations.map(&:id)

      @edition.save!

      @attachment = FactoryBot.build(:image_with_no_assets, edition: @edition)
      @attachment.image_data.images << @attachment
      @asset_manager_response = { "id" => "http://asset-manager/assets/asset_manager_id", "name" => @filename }
      Services.asset_manager.stubs(:asset).returns(@asset_manager_response)
      Services.asset_manager.stubs(:create_asset).returns(@asset_manager_response)
    end

    test "sends the user ids of authorised users to Asset Manager" do
      Services.asset_manager.expects(:create_asset)
              .with(has_entry(access_limited_organisation_ids: @edition.organisations.map(&:content_id)))
              .returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @attachment.save!
      end
    end

    test "marks the attachment as draft in Asset Manager" do
      Services.asset_manager.expects(:create_asset)
              .at_least_once
              .with(has_entry(draft: true))
              .returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @attachment.save!
      end
    end
  end

  class CreatingAnOrganisationLogo < ActiveSupport::TestCase
    setup do
      @filename = "960x640_jpeg.jpg"
      @organisation = FactoryBot.build(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(fixture_path.join("images", @filename)),
      )
      @response = { "id" => "http://asset-manager/assets/asset-id", "name" => @filename }
    end

    test "sends the logo to Asset Manager" do
      Services.asset_manager.expects(:create_asset).with { |args| File.basename(args[:file]) == @filename }.returns(@response)

      Sidekiq::Testing.inline! do
        @organisation.save!
      end
    end

    test "does not mark the logo as draft in Asset Manager" do
      Services.asset_manager.expects(:create_asset).with(has_entry(draft: false)).returns(@response)

      Sidekiq::Testing.inline! do
        @organisation.save!
      end
    end
  end

  class RemovingAnOrganisationLogo < ActiveSupport::TestCase
    test "removing an organisation logo removes it from asset manager" do
      logo_asset_manager_id = "logo_asset_manager_id"
      response = { "id" => "http://asset-manager/assets/#{logo_asset_manager_id}", "name" => "960x640_jpeg.jpg" }
      organisation = FactoryBot.create(:organisation_with_logo_and_assets)

      Services.asset_manager.stubs(:asset).with(logo_asset_manager_id).returns(response)
      Services.asset_manager.expects(:delete_asset).with(logo_asset_manager_id)

      Sidekiq::Testing.inline! do
        organisation.logo.remove!
      end
    end
  end

  class ReplacingAnOrganisationLogo < ActiveSupport::TestCase
    test "replacing an organisation logo removes the old logo from asset manager" do
      logo_asset_manager_id = "logo_asset_manager_id"
      response = { "id" => "http://asset-manager/assets/#{logo_asset_manager_id}", "name" => "960x640_jpeg.jpg" }
      Services.asset_manager.stubs(:create_asset).returns(response)
      organisation = FactoryBot.create(:organisation_with_logo_and_assets)

      Services.asset_manager.stubs(:asset).with(logo_asset_manager_id).returns(response)
      Services.asset_manager.expects(:delete_asset).with(logo_asset_manager_id)

      organisation.logo = File.open(fixture_path.join("images", "960x640_gif.gif"))

      Sidekiq::Testing.inline! do
        organisation.save!
      end
    end
  end

  class CreatingAPersonImage < ActiveSupport::TestCase
    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @person = FactoryBot.build(:person, :with_image)
      @expected_number_of_versions = @person.image.file.versions.keys.push(:original).size
      @response = { "id" => "http://asset-manager/assets/asset-id", "name" => @filename }
    end

    test "sends original and all versions of the image to Asset Manager" do
      Services.asset_manager.expects(:create_asset).with { |args| args[:file].path =~ /#{@filename}/ }.returns(@response)
      %w[s960 s712 s630 s465 s300 s216].each do |version_prefix|
        Services.asset_manager.expects(:create_asset).with { |args| args[:file].path =~ /#{version_prefix}_#{@filename}/ }.returns(@response)
      end

      Sidekiq::Testing.inline! do
        @person.save!
      end
    end

    test "does not mark the image as draft in Asset Manager" do
      Services.asset_manager.expects(:create_asset).with(has_entry(draft: false)).returns(@response).times(@expected_number_of_versions)

      Sidekiq::Testing.inline! do
        @person.save!
      end
    end
  end

  class ReplacingAPersonImage < ActiveSupport::TestCase
    setup do
      @person = FactoryBot.create(:person, :with_image)
      @expected_number_of_versions = @person.image.file.versions.keys.push(:original).size
      @replacement_filename = "big-cheese.960x640.jpg"
    end

    test "sends the new image and its versions to asset manager but also keeps the previous assets in asset manager" do
      Services.asset_manager.expects(:create_asset)
              .with { |args| args[:file].path =~ /#{@replacement_filename}/ }
              .returns("id" => "http://asset-manager/assets/asset_manager_id", "name" => @replacement_filename)
              .times(@expected_number_of_versions)

      # We keep the original assets (original & variants) of Person as other pages (e.g. Speech) might be using them
      Services.asset_manager.expects(:delete_asset).never

      Sidekiq::Testing.inline! do
        @person.update(image_attributes: {
          id: @person.image.id,
          file: File.open(fixture_path.join(@replacement_filename)),
        })
      end
    end
  end

  class CreatingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      @filename = "greenpaper.pdf"
      @asset_manager_response = { "id" => "http://asset-manager/assets/asset_manager_id", "name" => @filename }
      Services.asset_manager.stubs(:asset).returns(@asset_manager_response)

      consultation = create(:draft_consultation)
      participation = create(:consultation_participation, consultation:)
      response_form = build(
        :consultation_response_form,
        consultation_participation: participation,
      )

      @consultation_response_form_data = response_form.consultation_response_form_data
      @consultation_response_form_data.file = File.open(fixture_path.join(@filename))
    end

    test "sends the consultation response form data file to Asset Manager" do
      Services.asset_manager.expects(:create_asset).with { |args|
        args[:file].path =~ /#{@filename}/
      }.returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.save!
      end
    end

    test "sends draft as true for consultation response form data to Asset Manager" do
      Services.asset_manager.expects(:create_asset).with(has_entry(draft: true)).returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.save!
      end
    end
  end

  class CreatingAnAuthorisedConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      @filename = "greenpaper.pdf"
      @asset_manager_response = { "id" => "http://asset-manager/assets/asset_manager_id", "name" => @filename }
      Services.asset_manager.stubs(:asset).returns(@asset_manager_response)

      @organisation = create(:organisation)
      consultation = create(
        :draft_consultation,
        access_limiting: "organisations",
        access_limiting_organisation_ids: [@organisation.id],
        organisations: [@organisation],
      )
      response_form = build(:consultation_response_form, consultation_participation: nil)
      create(:consultation_participation, consultation:, consultation_response_form: response_form)
      consultation.reload

      @consultation_response_form_data = response_form.consultation_response_form_data
    end

    test "sends the access limited organisation ids to Asset Manager" do
      Services.asset_manager.expects(:create_asset)
              .with(has_entry(access_limited_organisation_ids: [@organisation.content_id]))
              .returns(@asset_manager_response)

      AssetManagerCreateAssetJob.drain
    end
  end

  class RemovingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      filename = "greenpaper.pdf"
      consultation = create(:draft_consultation)
      participation = create(:consultation_participation, consultation:)
      response_form = create(
        :consultation_response_form,
        consultation_participation: participation,
        file: File.open(fixture_path.join(filename)),
      )
      @consultation_response_form_data = response_form.consultation_response_form_data

      @asset_manager_id = @consultation_response_form_data.assets.first.asset_manager_id
      Services.asset_manager.stubs(:asset).with(@asset_manager_id).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}", "name" => filename)
    end

    test "removing a consultation response form data file removes it from asset manager" do
      Services.asset_manager.expects(:delete_asset)
              .with(@asset_manager_id)

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.file.remove!
      end
    end
  end

  class ReplacingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      filename = "greenpaper.pdf"
      consultation = create(:draft_consultation)
      participation = create(:consultation_participation, consultation:)
      response_form = create(
        :consultation_response_form,
        consultation_participation: participation,
        file: File.open(fixture_path.join(filename)),
      )
      @consultation_response_form_data = response_form.consultation_response_form_data

      @asset_manager_id = @consultation_response_form_data.assets.first.asset_manager_id
      Services.asset_manager.stubs(:asset).returns("id" => "http://asset-manager/assets/#{@asset_manager_id}", "name" => filename)
    end

    test "replacing a consultation response form data file removes the old file from asset manager" do
      replacement_filename = "whitepaper.pdf"
      Services.asset_manager.expects(:create_asset).with { |args|
        args[:file].path =~ /#{replacement_filename}/
      }.returns({ "id" => "http://asset-manager/assets/asset_manager_id_new", "name" => replacement_filename })
      Services.asset_manager.expects(:delete_asset).with(@asset_manager_id)
      @consultation_response_form_data.file = File.open(fixture_path.join(replacement_filename))

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.save!
      end
    end
  end

  class CreatingACallForEvidenceResponseFormData < ActiveSupport::TestCase
    setup do
      @filename = "greenpaper.pdf"
      @asset_manager_response = {
        "id" => "http://asset-manager/assets/asset_manager_id",
        "name" => @filename,
      }
      Services.asset_manager.stubs(:asset).returns(@asset_manager_response)

      call_for_evidence = create(:draft_call_for_evidence)
      participation = create(
        :call_for_evidence_participation,
        call_for_evidence:,
      )
      response_form = build(
        :call_for_evidence_response_form,
        call_for_evidence_participation: participation,
      )

      @call_for_evidence_response_form_data =
        response_form.call_for_evidence_response_form_data
      @call_for_evidence_response_form_data.file =
        File.open(fixture_path.join(@filename))
    end

    test "sends the call for evidence response form data file to Asset Manager" do
      Services.asset_manager.expects(:create_asset).with { |args|
        args[:file].path =~ /#{@filename}/
      }.returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @call_for_evidence_response_form_data.save!
      end
    end

    test "sends draft as true for call for evidence response form data to Asset Manager" do
      Services.asset_manager.expects(:create_asset)
              .with(has_entry(draft: true))
              .returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @call_for_evidence_response_form_data.save!
      end
    end
  end

  class CreatingAnAuthorisedCallForEvidenceResponseFormData < ActiveSupport::TestCase
    setup do
      @filename = "greenpaper.pdf"
      @asset_manager_response = { "id" => "http://asset-manager/assets/asset_manager_id", "name" => @filename }
      Services.asset_manager.stubs(:asset).returns(@asset_manager_response)

      @organisation = create(:organisation)
      call_for_evidence = create(
        :draft_call_for_evidence,
        access_limiting: "organisations",
        access_limiting_organisation_ids: [@organisation.id],
        organisations: [@organisation],
      )
      response_form = build(:call_for_evidence_response_form, call_for_evidence_participation: nil)
      create(:call_for_evidence_participation, call_for_evidence:, call_for_evidence_response_form: response_form)
      call_for_evidence.reload

      @call_for_evidence_response_form_data = response_form.call_for_evidence_response_form_data
    end

    test "sends the access limited organisation ids to Asset Manager" do
      Services.asset_manager.expects(:create_asset)
              .with(has_entry(access_limited_organisation_ids: [@organisation.content_id]))
              .returns(@asset_manager_response)

      AssetManagerCreateAssetJob.drain
    end
  end
end
