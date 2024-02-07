require "test_helper"

class AssetManagerIntegrationTest
  class CreatingAFileAttachment < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "sample.docx"
      @edition = create(:draft_publication)
      @attachment = FactoryBot.build(:file_attachment_with_no_assets, file: file_fixture(@filename), attachable: @edition)
      @asset_manager_response = { "id" => "http://asset-manager/assets/asset_manager_id", "name" => @filename }
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
      consultation = FactoryBot.create(:consultation, access_limited: true, organisations: [organisation])
      @attachment.attachable = consultation
      @attachment.attachment_data.attachable = consultation
      @attachment.save!

      Services.asset_manager.expects(:create_asset).with(has_entry(access_limited_organisation_ids: [organisation.content_id]))
              .returns(@asset_manager_response)

      AssetManagerCreateAssetWorker.drain
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
      ImageUploader.versions.each_key do |version_prefix|
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
      ConsultationResponseFormData.any_instance.stubs(:auth_bypass_ids).returns([])
      @consultation_response_form_data = FactoryBot.build(
        :consultation_response_form_data,
        file: File.open(fixture_path.join(@filename)),
      )
    end

    test "sends the consultation response form data file to Asset Manager" do
      Services.asset_manager.expects(:create_asset).with { |args|
        args[:file].path =~ /#{@filename}/
      }.returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.save!
      end
    end

    test "sends draft as false for consultation response form data to Asset Manager" do
      Services.asset_manager.expects(:create_asset).with(has_entry(draft: false)).returns(@asset_manager_response)

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.save!
      end
    end
  end

  class RemovingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      filename = "greenpaper.pdf"
      ConsultationResponseFormData.any_instance.stubs(:auth_bypass_ids).returns([])
      @consultation_response_form_data = FactoryBot.create(
        :consultation_response_form_data,
        file: File.open(fixture_path.join(filename)),
      )

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
      ConsultationResponseFormData.any_instance.stubs(:auth_bypass_ids).returns([])
      @consultation_response_form_data = FactoryBot.create(
        :consultation_response_form_data,
        file: File.open(fixture_path.join(filename)),
      )

      @asset_manager_id = @consultation_response_form_data.assets.first.asset_manager_id
      Services.asset_manager.stubs(:asset).with(@asset_manager_id).returns({ "id" => "http://asset-manager/assets/#{@asset_manager_id}", "name" => filename })
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
end
