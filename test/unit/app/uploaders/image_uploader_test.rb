require "test_helper"

class ImageUploaderTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  extend Minitest::Spec::DSL

  setup do
    ImageUploader.enable_processing = true
  end

  teardown do
    ImageUploader.enable_processing = false
  end

  test "uses the previewable asset manager storage engine" do
    assert_equal Storage::PreviewableStorage, ImageUploader.storage
  end

  test "should only allow JPG, GIF, PNG or SVG images" do
    uploader = ImageUploader.new
    assert_equal %w[jpg jpeg gif png svg], uploader.extension_allowlist
  end

  test "should send correctly resized versions of a bitmap image to asset manager" do
    create(:image_data_with_no_assets)

    Services.asset_manager.expects(:create_asset).with { |value|
      image_path = value[:file].path
      assert_image_has_correct_size image_path
    }.times(7).returns("id" => "http://asset-manager/assets/some-id", "name" => "minister-of-funk.960x640.jpg")

    AssetManagerCreateAssetWorker.drain
  end

  test "should store uploads in a directory that persists across deploys" do
    image_data = build(:image_data)
    @uploader = ImageUploader.new(image_data, "mounted-as")

    assert_match %r{^system}, @uploader.store_dir
  end

  test "should store all the versions of a bitmap image in asset manager" do
    expected_file_names = %w[minister-of-funk.960x640.jpg s960_minister-of-funk.960x640.jpg s712_minister-of-funk.960x640.jpg s630_minister-of-funk.960x640.jpg s465_minister-of-funk.960x640.jpg s300_minister-of-funk.960x640.jpg s216_minister-of-funk.960x640.jpg]
    create(:image_data_with_no_assets)

    Services.asset_manager.expects(:create_asset).with { |params|
      file = params[:file].path.split("/").last
      assert expected_file_names.include?(file)
    }.times(7).returns("id" => "http://asset-manager/assets/some-id", "name" => "minister-of-funk.960x640.jpg")

    AssetManagerCreateAssetWorker.drain
  end

  test "should store only the original version of a svg image in asset manager" do
    svg = upload_fixture("images/test-svg.svg", "image/svg+xml")
    ImageData.create!(file: svg)

    Services.asset_manager.stubs(:create_asset).with { |params|
      assert params[:file].path.split("/").last == "test-svg.svg"
    }.once.returns("id" => "http://asset-manager/assets/some-id", "name" => "test-svg.svg")

    AssetManagerCreateAssetWorker.drain
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
