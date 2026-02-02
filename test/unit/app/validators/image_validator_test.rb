require "test_helper"
require_relative "../../../../lib/whitehall/image_kinds"

class ImageValidatorTest < ActiveSupport::TestCase
  def setup
    @example_model = FeaturedImageData
  end

  test "should return range for bitmap image with defined config" do
    jpeg_example = build_example("960x640_jpeg.jpg")

    assert_equal jpeg_example.file.height_range, (jpeg_example.image_kind_config.valid_height..jpeg_example.image_kind_config.valid_height)
    assert_equal jpeg_example.file.width_range, (jpeg_example.image_kind_config.valid_width..jpeg_example.image_kind_config.valid_width)
  end

  test "should not return range for non-bitmap image with defined config" do
    svg_example = build_example("test-svg.svg")

    assert_nil svg_example.file.height_range
    assert_nil svg_example.file.width_range
  end

private

  def build_example(file_name)
    if file_name.present?
      File.open(Rails.root.join("test/fixtures/images", file_name)) do |file|
        @example_model.new(file:).tap do |image_data|
          carrierwave_file = image_data.file.file
          if carrierwave_file
            carrierwave_file.content_type = content_type(file_name)
          end
        end
      end
    else
      @example_model.new
    end
  end

  def content_type(file_name)
    types = {
      ".jpg" => "image/jpg",
      ".svg" => "image/svg+xml",
      ".gif" => "image/gif",
    }

    types[File.extname(file_name)]
  end
end
