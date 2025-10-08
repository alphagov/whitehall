require "test_helper"
require_relative "../../../../lib/whitehall/image_kinds"

class ImageValidatorTest < ActiveSupport::TestCase
  def setup
    @example_model = ImageData
  end

  test "should accept a good jpeg image" do
    assert_validates_as_valid(ImageValidator.new, "960x640_jpeg.jpg")
  end

  test "should not accept a gif pretending to be a jpeg" do
    assert_validates_as_invalid(ImageValidator.new, "960x640_gif_pretending_to_be_jpeg.jpg")
  end

  test "should not care about the case of the file extension" do
    assert_validates_as_valid(ImageValidator.new, "960x640_jpeg_with_uppercase_extension.JPG")
  end

  test "should allow specified mime-types" do
    subject = ImageValidator.new(mime_types: {
      "image/gif" => /.gif$/,
    })

    assert_validates_as_invalid(subject, "960x640_jpeg.jpg")
    assert_validates_as_valid(subject, "960x640_gif.gif")
  end

  test "with image kind config on the model it should only accept original images of a valid size" do
    @example_model = Class.new(ImageData) do
      def image_kind_config
        Whitehall::ImageKind.new(
          "some image kind",
          "display_name" => "some image kind display name",
          "permitted_uses" => [],
          "valid_width" => 300,
          "valid_height" => 1000,
          "versions" => [],
        )
      end
    end

    subject = ImageValidator.new

    assert_validates_as_invalid(subject, "50x33_gif.gif")
    assert_validates_as_valid(subject, "300x1000_png.png")
  end

  test "accepts any size if the model does not have image kind config" do
    @example_model = Class.new(ImageData) do
      undef_method :image_kind_config
    end

    subject = ImageValidator.new
    assert_validates_as_valid(subject, "50x33_gif.gif")
    assert_validates_as_valid(subject, "960x640_jpeg.jpg")
  end

  test "error type is :too_small when the image is too small" do
    subject = ImageValidator.new
    too_small = build_example("50x33_gif.gif")
    subject.validate(too_small)
    assert too_small.errors.of_kind?(:file, :too_small)
  end

  test "it should not throw an exception if a file isn't present" do
    subject = ImageValidator.new
    assert_nothing_raised do
      assert_validates_as_valid(subject, nil)
    end
  end

  test "it allows SVG" do
    subject = ImageValidator.new(size: [960, 640])
    assert_validates_as_valid(subject, "test-svg.svg")
  end

private

  def assert_validates_as_valid(validator, image_file_name)
    example = build_example(image_file_name)
    validator.validate(example)
    assert_not example.errors.any?
  end

  def assert_validates_as_invalid(validator, image_file_name)
    example = build_example(image_file_name)
    validator.validate(example)
    assert example.errors.any?
  end

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
