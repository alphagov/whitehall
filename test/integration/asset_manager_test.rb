require 'test_helper'

class AssetManagerIntegrationTest
  class CreatingAnOrganisationLogo < ActiveSupport::TestCase
    test 'sends the logo to Asset Manager' do
      @filename = '960x640_jpeg.jpg'
      @organisation = FactoryGirl.build(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(Rails.root.join('test', 'fixtures', 'images', @filename))
      )

      Services.asset_manager.expects(:create_whitehall_asset).with do |args|
        args[:file].is_a?(File) &&
          args[:legacy_url_path] =~ /#{@filename}/
      end
      @organisation.save!
    end
  end

  class CreatingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      @filename = 'greenpaper.pdf'
      @consultation_response_form_data = FactoryGirl.build(
        :consultation_response_form_data,
        file: File.open(Rails.root.join('test', 'fixtures', @filename))
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

  class RemovingAnOrganisationLogo < ActiveSupport::TestCase
    test 'removing an organisation logo removes it from asset manager' do
      @organisation = FactoryGirl.create(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(Rails.root.join('test', 'fixtures', 'images', '960x640_jpeg.jpg'))
      )

      @organisation.reload

      Services.asset_manager.stubs(:whitehall_asset).returns('id' => 'http://asset-manager/assets/asset-id')
      Services.asset_manager.stubs(:delete_asset)

      Services.asset_manager.expects(:delete_asset)

      @organisation.remove_logo!
    end
  end

  class ReplacingAnOrganisationLogo < ActiveSupport::TestCase
    test 'replacing an organisation logo removes the old logo from asset manager' do
      @old_logo_filename = '960x640_jpeg.jpg'
      @organisation = FactoryGirl.create(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(Rails.root.join('test', 'fixtures', 'images', @old_logo_filename))
      )

      @organisation.reload

      old_logo_asset_id = 'asset-id'
      Services.asset_manager.stubs(:whitehall_asset)
        .with(regexp_matches(/#{@old_logo_filename}/))
        .returns('id' => "http://asset-manager/assets/#{old_logo_asset_id}")
      Services.asset_manager.expects(:delete_asset).with(old_logo_asset_id)

      @organisation.logo = File.open(Rails.root.join('test', 'fixtures', 'images', '960x640_gif.gif'))
      @organisation.save!
    end
  end

  class RemovingAConsultationResponseFormData < ActiveSupport::TestCase
    setup do
      @consultation_response_form_data = FactoryGirl.create(
        :consultation_response_form_data,
        file: File.open(Rails.root.join('test', 'fixtures', 'greenpaper.pdf'))
      )
      VirusScanHelpers.simulate_virus_scan(@consultation_response_form_data.file)
      @consultation_response_form_data.reload
      @file_path = @consultation_response_form_data.file.path

      Services.asset_manager.stubs(:whitehall_asset).returns('id' => 'http://asset-manager/assets/asset-id')
      Services.asset_manager.stubs(:delete_asset)
    end

    test 'removing a consultation response form data file removes it from the file system' do
      assert File.exist?(@file_path)

      @consultation_response_form_data.remove_file!

      refute File.exist?(@file_path)
    end

    test 'removing a consultation response form data file removes it from asset manager' do
      Services.asset_manager.expects(:delete_asset)

      @consultation_response_form_data.remove_file!
    end
  end
end
