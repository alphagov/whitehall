require 'test_helper'

class AssetRemoverTest < ActiveSupport::TestCase
  setup do
    @logo_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'organisation', 'logo')
    @logo_path = File.join(@logo_dir, '960x640_jpeg.jpg')
    fixture_asset_path = Rails.root.join('test', 'fixtures', 'images', '960x640_jpeg.jpg')

    FileUtils.mkdir_p(@logo_dir)
    FileUtils.cp(fixture_asset_path, @logo_path)

    @subject = AssetRemover.new
  end

  teardown do
    FileUtils.remove_dir(@logo_dir, true)
  end

  test '#remove_organisation_logos removes all logos' do
    assert File.exist?(@logo_path)

    @subject.remove_organisation_logos

    refute File.exist?(@logo_path)
  end

  test '#remove_organisation_logos removes the containing directory' do
    assert Dir.exist?(@logo_dir)

    @subject.remove_organisation_logos

    refute Dir.exist?(@logo_dir)
  end

  test '#remove_organisation_logos returns an array of the files removed' do
    files = @subject.remove_organisation_logos

    assert_equal [@logo_path], files
  end
end
