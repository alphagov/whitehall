require "test_helper"

class AssetManagerIntegrationTest
  class CreatingAFileAttachment < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "960x640_jpeg.jpg"
      @attachment = FactoryBot.build(
        :file_attachment,
        file: File.open(fixture_path.join("images", @filename)),
      )
    end

    describe "use_non_legacy_endpoints is false" do
      test "sends the attachment to Asset Manager" do
        Services.asset_manager.expects(:create_whitehall_asset).with(file_and_legacy_url_path_matching(/#{@filename}/))

        Sidekiq::Testing.inline! do
          @attachment.save!
        end
      end

      test "marks the attachment as draft in Asset Manager" do
        Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(draft: true))

        Sidekiq::Testing.inline! do
          @attachment.save!
        end
      end

      test "sends the user ids of authorised users to Asset Manager" do
        organisation = FactoryBot.create(:organisation)
        user = FactoryBot.create(:user, organisation:, uid: "user-uid")
        consultation = FactoryBot.create(:consultation, access_limited: true, organisations: [organisation])
        @attachment.attachable = consultation
        @attachment.attachment_data.attachable = consultation
        @attachment.save!

        Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(access_limited: [user.uid]))

        AssetManagerCreateWhitehallAssetWorker.drain
      end
    end

    describe "use_non_legacy_endpoints is true" do
      setup do
        @attachment.attachment_data.use_non_legacy_endpoints = true
      end

      test "sends the attachment to Asset Manager" do
        Services.asset_manager.expects(:asset).with(anything).returns("id" => "http://asset-manager/assets/asset_manager_id")
        Services.asset_manager.expects(:create_asset).with(file_matching(/#{@filename}/)).returns("id" => "http://asset-manager/assets/asset_manager_id")

        Sidekiq::Testing.inline! do
          @attachment.save!
        end
      end

      test "marks the attachment as draft in Asset Manager" do
        Services.asset_manager.expects(:asset).with(anything).returns("id" => "http://asset-manager/assets/asset_manager_id")
        Services.asset_manager.expects(:create_asset).with(has_entry(draft: true))
                .returns("id" => "http://asset-manager/assets/asset_manager_id")

        Sidekiq::Testing.inline! do
          @attachment.save!
        end
      end

      test "sends the user ids of authorised users to Asset Manager" do
        organisation = FactoryBot.create(:organisation)
        user = FactoryBot.create(:user, organisation:, uid: "user-uid")
        consultation = FactoryBot.create(:consultation, access_limited: true, organisations: [organisation])
        @attachment.attachable = consultation
        @attachment.attachment_data.attachable = consultation
        @attachment.save!

        Services.asset_manager.expects(:create_asset).with(has_entry(access_limited: [user.uid]))
                .returns("id" => "http://asset-manager/assets/asset_manager_id")

        AssetManagerCreateAssetWorker.drain
      end
    end
  end

  class CreatingAnOrganisationLogo < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "960x640_jpeg.jpg"
      @organisation = FactoryBot.build(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(fixture_path.join("images", @filename)),
      )
    end

    context "use_non_legacy_endpoints is false" do
      test "sends the logo to Asset Manager" do
        Services.asset_manager.expects(:create_whitehall_asset).with(file_and_legacy_url_path_matching(/#{@filename}/))

        Sidekiq::Testing.inline! do
          @organisation.save!
        end
      end

      test "does not mark the logo as draft in Asset Manager" do
        Services.asset_manager.expects(:create_whitehall_asset).with(has_entries(draft: false))

        Sidekiq::Testing.inline! do
          @organisation.save!
        end
      end
    end

    context "use_non_legacy_endpoints is true" do
      setup do
        @organisation.use_non_legacy_endpoints = true
      end

      test "sends the logo to Asset Manager" do
        Services.asset_manager.expects(:create_asset).with { |params|
          params[:file].path =~ /#{@filename}/
        }.once.returns("id" => "http://asset-manager/assets/asset_manager_id")

        Sidekiq::Testing.inline! do
          @organisation.save!
        end
      end

      test "does not mark the logo as draft in Asset Manager" do
        Services.asset_manager.expects(:create_asset).with(has_entry(draft: false)).returns("id" => "http://asset-manager/assets/asset_manager_id")

        Sidekiq::Testing.inline! do
          @organisation.save!
        end
      end
    end
  end

  class RemovingAnOrganisationLogo < ActiveSupport::TestCase
    test "removing an organisation logo removes it from asset manager" do
      logo_filename = "960x640_jpeg.jpg"
      organisation = FactoryBot.create(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(fixture_path.join("images", logo_filename)),
      )
      logo_asset_id = "asset-id"
      Services.asset_manager.stubs(:whitehall_asset)
              .with(regexp_matches(/#{logo_filename}/))
              .returns("id" => "http://asset-manager/assets/#{logo_asset_id}")

      Services.asset_manager.expects(:delete_asset).with(logo_asset_id)

      Sidekiq::Testing.inline! do
        organisation.logo.remove!
      end
    end
  end

  class ReplacingAnOrganisationLogo < ActiveSupport::TestCase
    test "replacing an organisation logo removes the old logo from asset manager" do
      old_logo_filename = "960x640_jpeg.jpg"
      organisation = FactoryBot.create(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(fixture_path.join("images", old_logo_filename)),
      )
      old_logo_asset_id = "asset-id"
      Services.asset_manager.stubs(:whitehall_asset)
              .with(regexp_matches(/#{old_logo_filename}/))
              .returns("id" => "http://asset-manager/assets/#{old_logo_asset_id}")

      Services.asset_manager.expects(:delete_asset).with(old_logo_asset_id)

      organisation.logo = File.open(fixture_path.join("images", "960x640_gif.gif"))

      Sidekiq::Testing.inline! do
        organisation.save!
      end
    end
  end

  class CreatingAPersonImage < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @person = FactoryBot.build(
        :person,
        image: File.open(fixture_path.join(@filename)),
      )
    end

    context "use_non_legacy_endpoints is false" do
      setup do
        Services.asset_manager.stubs(:create_whitehall_asset)
      end

      test "sends the person image to Asset Manager" do
        Services.asset_manager.expects(:create_whitehall_asset).with(file_and_legacy_url_path_matching(/#{@filename}/))

        Sidekiq::Testing.inline! do
          @person.save!
        end
      end

      test "does not mark the image as draft in Asset Manager" do
        Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(draft: false))

        Sidekiq::Testing.inline! do
          @person.save!
        end
      end

      test "sends each version of the person image to Asset Manager" do
        ImageUploader.versions.each_key do |version_prefix|
          Services.asset_manager.expects(:create_whitehall_asset).with(
            file_and_legacy_url_path_matching(/#{version_prefix}_#{@filename}/),
          )
        end

        Sidekiq::Testing.inline! do
          @person.save!
        end
      end
    end

    context "use_non_legacy_endpoints is true" do
      setup do
        @person.use_non_legacy_endpoints = true
      end

      test "does not mark the image as draft in Asset Manager" do
        Services.asset_manager.expects(:create_asset).with(has_entry(draft: false)).returns("id" => "http://asset-manager/assets/asset_manager_id").times(7)

        Sidekiq::Testing.inline! do
          @person.save!
        end
      end

      test "sends original and each version of the person image to Asset Manager" do
        expected_file_names = %w[minister-of-funk.960x640.jpg s960_minister-of-funk.960x640.jpg s712_minister-of-funk.960x640.jpg s630_minister-of-funk.960x640.jpg s465_minister-of-funk.960x640.jpg s300_minister-of-funk.960x640.jpg s216_minister-of-funk.960x640.jpg]

        Services.asset_manager.expects(:create_asset).with { |params|
          file = params[:file].path.split("/").last
          assert expected_file_names.include?(file)
        }.times(7).returns("id" => "http://asset-manager/assets/some-id")

        Sidekiq::Testing.inline! do
          @person.save!
        end
      end
    end
  end

  class RemovingAPersonImage < ActiveSupport::TestCase
    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @person = FactoryBot.create(
        :person,
        image: File.open(fixture_path.join(@filename)),
      )

      @person.reload

      @asset_id = "asset-id"
      Services.asset_manager.stubs(:whitehall_asset).returns("id" => "http://asset-manager/assets/#{@asset_id}")
    end

    test "removes the person image and all its versions from asset manager" do
      # Creating a person creates one asset record in asset manager
      # for the uploaded asset and one asset record for each of the
      # versions defined in ImageUploader.
      expected_number_of_versions = @person.image.versions.size + 1
      Services.asset_manager.expects(:delete_asset).with(@asset_id).times(expected_number_of_versions)

      Sidekiq::Testing.inline! do
        @person.image.remove!
      end
    end
  end

  class ReplacingAPersonImage < ActiveSupport::TestCase
    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @person = FactoryBot.create(
        :person,
        image: File.open(fixture_path.join(@filename)),
      )

      @person.reload
    end

    test "sends the new image and its versions to asset manager" do
      expected_number_of_versions = @person.image.versions.size + 1
      Services.asset_manager.expects(:create_whitehall_asset).times(expected_number_of_versions)

      @person.image = File.open(fixture_path.join("big-cheese.960x640.jpg"))

      Sidekiq::Testing.inline! do
        @person.save!
      end
    end

    test "does not remove the original images from asset manager" do
      Services.asset_manager.expects(:delete_asset).never

      @person.image = File.open(fixture_path.join("big-cheese.960x640.jpg"))

      Sidekiq::Testing.inline! do
        @person.save!
      end
    end
  end

  class CreatingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      @filename = "greenpaper.pdf"
      ConsultationResponseFormData.any_instance.stubs(:auth_bypass_ids).returns([])
      @consultation_response_form_data = FactoryBot.build(
        :consultation_response_form_data,
        file: File.open(fixture_path.join(@filename)),
      )
    end

    test "sends the consultation response form data file to Asset Manager" do
      Services.asset_manager.expects(:create_whitehall_asset).with(
        file_and_legacy_url_path_matching(/#{@filename}/),
      )

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.save!
      end
    end

    test "does not mark the consultation response form data as draft in Asset Manager" do
      Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(draft: false))

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.save!
      end
    end
  end

  class RemovingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      filename = "greenpaper.pdf"
      @consultation_response_form_asset_id = "asset-id"
      ConsultationResponseFormData.any_instance.stubs(:auth_bypass_ids).returns([])
      @consultation_response_form_data = FactoryBot.create(
        :consultation_response_form_data,
        file: File.open(fixture_path.join(filename)),
      )
      @consultation_response_form_data.reload
      @file_path = @consultation_response_form_data.file.path

      Services.asset_manager.stubs(:whitehall_asset)
              .with(regexp_matches(/#{filename}/))
              .returns("id" => "http://asset-manager/assets/#{@consultation_response_form_asset_id}")
      Services.asset_manager.stubs(:delete_asset)
    end

    test "removing a consultation response form data file removes it from asset manager" do
      Services.asset_manager.expects(:delete_asset)
              .with(@consultation_response_form_asset_id)

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.file.remove!
      end
    end
  end

  class ReplacingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      filename = "greenpaper.pdf"
      @consultation_response_form_asset_id = "asset-id"
      ConsultationResponseFormData.any_instance.stubs(:auth_bypass_ids).returns([])
      @consultation_response_form_data = FactoryBot.create(
        :consultation_response_form_data,
        file: File.open(fixture_path.join(filename)),
      )
      @consultation_response_form_data.reload
      @file_path = @consultation_response_form_data.file.path

      Services.asset_manager.stubs(:whitehall_asset)
              .with(regexp_matches(/#{filename}/))
              .returns("id" => "http://asset-manager/assets/#{@consultation_response_form_asset_id}")
      Services.asset_manager.stubs(:delete_asset)
    end

    test "replacing a consultation response form data file removes the old file from asset manager" do
      Services.asset_manager.expects(:delete_asset)
              .with(@consultation_response_form_asset_id)

      @consultation_response_form_data.file = File.open(fixture_path.join("whitepaper.pdf"))

      Sidekiq::Testing.inline! do
        @consultation_response_form_data.save!
      end
    end
  end

  class CreatingAFeatureImage < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @feature = FactoryBot.build(
        :feature,
        image: File.open(fixture_path.join(@filename)),
      )
    end

    context "use_non_legacy_endpoints is true" do
      setup do
        @feature.use_non_legacy_endpoints = true
      end

      test "does not mark the image as draft in Asset Manager" do
        Services.asset_manager.expects(:create_asset).with(has_entry(draft: false)).returns("id" => "http://asset-manager/assets/asset_manager_id").times(7)

        Sidekiq::Testing.inline! do
          @feature.save!
        end
      end

      test "sends original and each version of the person image to Asset Manager" do
        expected_file_names = %w[minister-of-funk.960x640.jpg s960_minister-of-funk.960x640.jpg s712_minister-of-funk.960x640.jpg s630_minister-of-funk.960x640.jpg s465_minister-of-funk.960x640.jpg s300_minister-of-funk.960x640.jpg s216_minister-of-funk.960x640.jpg]

        Services.asset_manager.stubs(:create_asset).with { |params|
          file = params[:file].path.split("/").last
          assert expected_file_names.include?(file)
        }.times(7).returns("id" => "http://asset-manager/assets/some-id")

        Sidekiq::Testing.inline! do
          @feature.save!
        end
      end
    end
  end

  class CreatingATopicalEventLogo < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @topical_event = FactoryBot.build(
        :topical_event,
        logo: File.open(fixture_path.join(@filename)),
      )
    end

    context "use_non_legacy_endpoints is true" do
      setup do
        @topical_event.use_non_legacy_endpoints = true
      end

      test "does not mark the image as draft in Asset Manager" do
        Services.asset_manager.expects(:create_asset).with(has_entry(draft: false)).returns("id" => "http://asset-manager/assets/asset_manager_id").times(7)

        Sidekiq::Testing.inline! do
          @topical_event.save!
        end
      end

      test "sends original and each version of the person image to Asset Manager" do
        expected_file_names = %w[minister-of-funk.960x640.jpg s960_minister-of-funk.960x640.jpg s712_minister-of-funk.960x640.jpg s630_minister-of-funk.960x640.jpg s465_minister-of-funk.960x640.jpg s300_minister-of-funk.960x640.jpg s216_minister-of-funk.960x640.jpg]

        Services.asset_manager.stubs(:create_asset).with { |params|
          file = params[:file].path.split("/").last
          assert expected_file_names.include?(file)
        }.times(7).returns("id" => "http://asset-manager/assets/some-id")

        Sidekiq::Testing.inline! do
          @topical_event.save!
        end
      end
    end
  end

  class CreatingATakePartPageImage < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @take_part_page = FactoryBot.build(
        :take_part_page,
        image: File.open(fixture_path.join(@filename)),
      )
    end

    context "use_non_legacy_endpoints is true" do
      setup do
        @take_part_page.use_non_legacy_endpoints = true
      end

      test "does not mark the image as draft in Asset Manager" do
        Services.asset_manager.expects(:create_asset).with(has_entry(draft: false)).returns("id" => "http://asset-manager/assets/asset_manager_id").times(7)

        Sidekiq::Testing.inline! do
          @take_part_page.save!
        end
      end

      test "sends original and each version of the person image to Asset Manager" do
        expected_file_names = %w[minister-of-funk.960x640.jpg s960_minister-of-funk.960x640.jpg s712_minister-of-funk.960x640.jpg s630_minister-of-funk.960x640.jpg s465_minister-of-funk.960x640.jpg s300_minister-of-funk.960x640.jpg s216_minister-of-funk.960x640.jpg]

        Services.asset_manager.expects(:create_asset).with { |params|
          file = params[:file].path.split("/").last
          assert expected_file_names.include?(file)
        }.times(7).returns("id" => "http://asset-manager/assets/some-id")

        Sidekiq::Testing.inline! do
          @take_part_page.save!
        end
      end
    end
  end

  class CreatingAPromotionalFeatureItemImage < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @filename = "minister-of-funk.960x640.jpg"
      @promotional_feature_item = FactoryBot.build(
        :promotional_feature_item,
        image: File.open(fixture_path.join(@filename)),
      )
    end

    context "use_non_legacy_endpoints is true" do
      setup do
        @promotional_feature_item.use_non_legacy_endpoints = true
      end

      test "sends original and each version of the person image to Asset Manager" do
        expected_file_names = %w[minister-of-funk.960x640.jpg s960_minister-of-funk.960x640.jpg s712_minister-of-funk.960x640.jpg s630_minister-of-funk.960x640.jpg s465_minister-of-funk.960x640.jpg s300_minister-of-funk.960x640.jpg s216_minister-of-funk.960x640.jpg]

        Services.asset_manager.expects(:create_asset).with { |params|
          file = params[:file].path.split("/").last
          assert expected_file_names.include?(file)
        }.times(7).returns("id" => "http://asset-manager/assets/some-id")

        Sidekiq::Testing.inline! do
          @promotional_feature_item.save!
        end
      end
    end
  end
end
