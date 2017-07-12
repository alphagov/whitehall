require 'test_helper'

class ImageUploaderTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    ImageUploader.enable_processing = true
  end

  teardown do
    ImageUploader.enable_processing = false
  end

  test "should only allow JPG, GIF, PNG or SVG images" do
    uploader = ImageUploader.new
    assert_equal %w(jpg jpeg gif png svg), uploader.extension_whitelist
  end

  test "should store uploads in a directory that persists across deploys" do
    model = stub("AR Model", id: 1)
    uploader = ImageUploader.new(model, "mounted-as")
    assert_match /^system/, uploader.store_dir
  end

  test "should create resized versions of a bitmap image" do
    model = stub("AR Model", id: 1)
    @uploader = ImageUploader.new(model, "mounted-as")

    @uploader.store!(fixture_file_upload('minister-of-funk.960x640.jpg', 'image/jpg'))

    [[712, 480], [630, 420], [465, 310], [300, 195], [216, 140]].each do |(width, height)|
      assert_image_size [width, height], @uploader.send(:"s#{width}")
    end
  end

  test "stores the original svg only" do
    model = stub("AR Model", id: 1)
    @uploader = ImageUploader.new(model, "mounted-as")

    @uploader.store!(fixture_file_upload('images/test-svg.svg', 'image/svg+xml'))

    [[712, 480], [630, 420], [465, 310], [300, 195], [216, 140]].each do |(width, _height)|
      assert_nil @uploader.send(:url, :"s#{width}")
    end
  end

private

  def assert_image_size(dimensions, uploader_version)
    width, height = dimensions
    image = MiniMagick::Image.open(uploader_version.path)
    assert_equal width, image[:width], "#{dimensions.join("x")} image version should be #{width}px wide, but was #{image[:width]}"
    assert_equal height, image[:height], "#{dimensions.join("x")} image version should be #{height}px high, but was #{image[:height]}"
  end
end
