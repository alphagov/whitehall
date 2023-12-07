require "test_helper"

class FeaturedImageUploaderTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  setup { FeaturedImageUploader.enable_processing = true }
  teardown { FeaturedImageUploader.enable_processing = false }

  test "uses the asset manager and quarantined file storage engine" do
    assert_equal Whitehall::AssetManagerStorage, FeaturedImageUploader.storage
  end

  test "should only allow JPG, GIF, PNG images" do
    uploader = FeaturedImageUploader.new
    assert_equal %w[jpg jpeg gif png], uploader.extension_allowlist
  end

  test "should send correctly resized versions of a bitmap image to asset manager" do
    uploader = FeaturedImageUploader.new(FactoryBot.create(:person), "mounted-as")
    response = { "id" => "http://asset-manager/assets/asset-id", "name" => "minister-of-funk.960x640.jpg" }
    Services.asset_manager.stubs(:create_asset)
    Services.asset_manager.expects(:create_asset).with { |value|
      image_path = value[:file].path
      assert_image_has_correct_size(image_path)
    }.returns(response).times(7)

    Sidekiq::Testing.inline! do
      uploader.store!(upload_fixture("minister-of-funk.960x640.jpg", "image/jpg"))
    end
  end

  test "should store uploads in a directory that persists across deploys" do
    uploader = FeaturedImageUploader.new(Person.new(id: 1), "mounted-as")
    assert_match %r{^system}, uploader.store_dir
  end

private

  def assert_image_has_correct_size(asset_path)
    filename = File.basename(asset_path)

    expected_sizes = {
      "minister-of-funk.960x640.jpg" => [960, 640],
      "s960_minister-of-funk.960x640.jpg" => [960, 640],
      "s712_minister-of-funk.960x640.jpg" => [712, 480],
      "s630_minister-of-funk.960x640.jpg" => [630, 420],
      "s465_minister-of-funk.960x640.jpg" => [465, 310],
      "s300_minister-of-funk.960x640.jpg" => [300, 195],
      "s216_minister-of-funk.960x640.jpg" => [216, 140],
    }

    width, height = expected_sizes[filename]
    image = MiniMagick::Image.open(asset_path)
    assert_equal width, image[:width], "#{expected_sizes[filename].join('x')} image version should be #{width}px wide, but was #{image[:width]}"
    assert_equal height, image[:height], "#{expected_sizes[filename].join('x')} image version should be #{height}px high, but was #{image[:height]}"
  end
end
