require 'test_helper'

class AssetManagerIntegrationTest
  class CreatingAnOrganisationLogo < ActiveSupport::TestCase
    test 'sends the logo to Asset Manager' do
      filename = '960x640_jpeg.jpg'
      organisation = FactoryBot.build(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(fixture_path.join('images', filename))
      )

      Services.asset_manager.expects(:create_whitehall_asset).with do |args|
        args[:file].is_a?(File) &&
          args[:legacy_url_path] =~ /#{filename}/
      end

      organisation.save!
    end
  end

  class RemovingAnOrganisationLogo < ActiveSupport::TestCase
    test 'removing an organisation logo removes it from asset manager' do
      logo_filename = '960x640_jpeg.jpg'
      organisation = FactoryBot.create(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(fixture_path.join('images', logo_filename))
      )
      logo_asset_id = 'asset-id'
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(/#{logo_filename}/))
        .returns('id' => "http://asset-manager/assets/#{logo_asset_id}")

      Services.asset_manager.expects(:delete_asset).with(logo_asset_id)

      organisation.remove_logo!
    end
  end

  class ReplacingAnOrganisationLogo < ActiveSupport::TestCase
    test 'replacing an organisation logo removes the old logo from asset manager' do
      old_logo_filename = '960x640_jpeg.jpg'
      organisation = FactoryBot.create(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(fixture_path.join('images', old_logo_filename))
      )
      old_logo_asset_id = 'asset-id'
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(/#{old_logo_filename}/))
        .returns('id' => "http://asset-manager/assets/#{old_logo_asset_id}")

      Services.asset_manager.expects(:delete_asset).with(old_logo_asset_id)

      organisation.logo = File.open(fixture_path.join('images', '960x640_gif.gif'))
      organisation.save!
    end
  end

  class CreatingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      @filename = 'greenpaper.pdf'
      @consultation_response_form_data = FactoryBot.build(
        :consultation_response_form_data,
        file: File.open(fixture_path.join(@filename))
      )
    end

    test 'sends the consultation response form data file to Asset Manager' do
      Services.asset_manager.expects(:create_whitehall_asset).with do |args|
        args[:file].is_a?(File) &&
          args[:legacy_url_path] =~ /#{@filename}/
      end

      @consultation_response_form_data.save!
    end

    test 'saves the consultation response form data file to the file system' do
      @consultation_response_form_data.save!

      assert File.exist?(@consultation_response_form_data.file.path)
    end
  end

  class RemovingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      filename = 'greenpaper.pdf'
      @consultation_response_form_asset_id = 'asset-id'
      @consultation_response_form_data = FactoryBot.create(
        :consultation_response_form_data,
        file: File.open(fixture_path.join(filename))
      )
      VirusScanHelpers.simulate_virus_scan(@consultation_response_form_data.file)
      @consultation_response_form_data.reload
      @file_path = @consultation_response_form_data.file.path

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(/#{filename}/))
        .returns('id' => "http://asset-manager/assets/#{@consultation_response_form_asset_id}")
      Services.asset_manager.stubs(:delete_asset)
    end

    test 'removing a consultation response form data file removes it from the file system' do
      assert File.exist?(@file_path)

      @consultation_response_form_data.remove_file!

      refute File.exist?(@file_path)
    end

    test 'removing a consultation response form data file removes it from asset manager' do
      Services.asset_manager.expects(:delete_asset)
        .with(@consultation_response_form_asset_id)

      @consultation_response_form_data.remove_file!
    end
  end

  class ReplacingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      filename = 'greenpaper.pdf'
      @consultation_response_form_asset_id = 'asset-id'
      @consultation_response_form_data = FactoryBot.create(
        :consultation_response_form_data,
        file: File.open(fixture_path.join(filename))
      )
      VirusScanHelpers.simulate_virus_scan(@consultation_response_form_data.file)
      @consultation_response_form_data.reload
      @file_path = @consultation_response_form_data.file.path

      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(/#{filename}/))
        .returns('id' => "http://asset-manager/assets/#{@consultation_response_form_asset_id}")
      Services.asset_manager.stubs(:delete_asset)
    end

    test 'replacing a consultation response form data file removes the old file from the file system' do
      assert File.exist?(@file_path)

      @consultation_response_form_data.file = File.open(fixture_path.join('whitepaper.pdf'))
      @consultation_response_form_data.save!

      refute File.exist?(@file_path)
    end

    test 'replacing a consultation response form data file removes the old file from asset manager' do
      Services.asset_manager.expects(:delete_asset)
        .with(@consultation_response_form_asset_id)

      @consultation_response_form_data.file = File.open(fixture_path.join('whitepaper.pdf'))
      @consultation_response_form_data.save!
    end
  end
end
