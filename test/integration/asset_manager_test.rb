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
end
