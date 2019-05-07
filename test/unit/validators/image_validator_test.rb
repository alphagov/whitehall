require 'test_helper'

class ImageValidatorTest < ActiveSupport::TestCase
  EXAMPLE_MODEL = ImageData

  test "should accept a good jpeg image" do
    assert_validates_as_valid(ImageValidator.new, "960x640_jpeg.jpg")
  end

  test "should not accept a gif pretending to be a jpeg" do
    assert_validates_as_invalid(ImageValidator.new, "960x640_gif_pretending_to_be_jpeg.jpg")
  end

  test "should not care about the case of the file extension" do
    assert_validates_as_valid(ImageValidator.new, "960x640_jpeg_with_uppercase_extension.JPG")
  end

  test "should not accept a corrupt image" do
    assert_validates_as_invalid(ImageValidator.new, "not_an_image.jpg")
  end

  test "should allow specified mime-types" do
    subject = ImageValidator.new(mime_types: {
      "image/gif" => /.gif$/
    })

    assert_validates_as_invalid(subject, "960x640_jpeg.jpg")
    assert_validates_as_valid(subject, "960x640_gif.gif")
  end

  test "with constrain_size option it should only accept original images of that size" do
    subject = ImageValidator.new(size: [960, 640])

    assert_validates_as_invalid(subject, "50x33_gif.gif")
    assert_validates_as_valid(subject, "960x640_jpeg.jpg")
  end

  test "it should not throw an exception if a file isn't present" do
    subject = ImageValidator.new
    assert_nothing_raised {
      assert_validates_as_valid(subject, nil)
    }
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
      File.open(File.join(Rails.root, 'test/fixtures/images', file_name)) do |file|
        EXAMPLE_MODEL.new(file: file).tap do |image_data|
          carrierwave_file = image_data.file.file
          carrierwave_file.content_type = content_type(file_name)
        end
      end
    else
      EXAMPLE_MODEL.new
    end
  end

  def content_type(file_name)
    extension = File.extname(file_name)
    case extension
    when ".jpg"
      "image/jpg"
    when ".svg"
      "image/svg+xml"
    when ".gif"
      "image/gif"
    end
  end
end
