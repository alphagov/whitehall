require 'test_helper'

class AssetManagerIntegrationTest
  class CreatingAnOrganisationLogo < ActiveSupport::TestCase
    setup do
      Whitehall.stubs(:use_asset_manager).returns(true)

      @filename = '960x640_jpeg.jpg'
      @organisation = FactoryGirl.build(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(Rails.root.join('test', 'fixtures', 'images', @filename))
      )
    end

    test 'sends the logo to Asset Manager' do
      Services.asset_manager.expects(:create_whitehall_asset).with do |args|
        args[:file].is_a?(File) &&
          args[:legacy_url_path] =~ /#{@filename}/
      end

      @organisation.save!
    end

    test 'saves the logo to the file system' do
      @organisation.save!

      assert File.exist?(@organisation.logo.path)
    end
  end

  class RemovingAnOrganisationLogo < ActiveSupport::TestCase
    setup do
      Whitehall.stubs(:use_asset_manager).returns(true)

      @organisation = FactoryGirl.create(
        :organisation,
        organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
        logo: File.open(Rails.root.join('test', 'fixtures', 'images', '960x640_jpeg.jpg'))
      )
      VirusScanHelpers.simulate_virus_scan(@organisation.logo)
      @organisation.reload

      Services.asset_manager.stubs(:whitehall_asset).returns('id' => 'http://asset-manager/assets/asset-id')
      Services.asset_manager.stubs(:delete_asset)
    end

    test 'removing an organisation logo removes it from the file system' do
      logo_path = @organisation.logo.path

      @organisation.remove_logo!
      @organisation.reload

      refute File.exist?(logo_path)
    end

    test 'removing an organisation logo removes it from asset manager' do
      Services.asset_manager.expects(:delete_asset)

      @organisation.remove_logo!
    end
  end
end
