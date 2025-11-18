require "test_helper"

class ConfigurableContentBlocks::FactoryTest < ActiveSupport::TestCase
  test "it raises an error if the block type does not exist" do
    page = StandardEdition.new
    error = assert_raises do
      ConfigurableContentBlocks::Factory.new(page).build("missing", "format")
    end
    assert_equal "No block is defined for the missing type format format", error.message
  end

  test "it raises an error if the block format does not exist" do
    page = StandardEdition.new
    error = assert_raises do
      ConfigurableContentBlocks::Factory.new(page).build("string", "missing")
    end
    assert_equal "No block is defined for the string type missing format", error.message
  end

  test "it can build a default object block" do
    page = StandardEdition.new
    factory = ConfigurableContentBlocks::Factory.new(page)
    block = mock("ConfigurableContentBlocks::DefaultObject")
    ConfigurableContentBlocks::DefaultObject.expects(:new).with(factory).returns(block)
    assert_equal block, factory.build("object")
  end

  test "it can build a default string block" do
    page = StandardEdition.new
    factory = ConfigurableContentBlocks::Factory.new(page)
    block = mock("ConfigurableContentBlocks::DefaultString")
    ConfigurableContentBlocks::DefaultString.expects(:new).returns(block)
    assert_equal block, factory.build("string")
  end

  test "it can build an image select integer block" do
    page = StandardEdition.new
    page.images = [build(:image)]
    factory = ConfigurableContentBlocks::Factory.new(page)
    block = mock("ConfigurableContentBlocks::ImageSelect")
    ConfigurableContentBlocks::ImageSelect.expects(:new).with(page.images).returns(block)
    assert_equal block, factory.build("integer", "image_select")
  end

  test "it can build a lead image select integer block" do
    page = StandardEdition.new
    img = create(:image)
    page.stubs(:default_lead_image).returns(img)
    placeholder_image_url = "http://example.com/placeholder.jpg"
    page.stubs(:placeholder_image_url).returns(placeholder_image_url)
    factory = ConfigurableContentBlocks::Factory.new(page)
    block = mock("ConfigurableContentBlocks::LeadImageSelect")
    ConfigurableContentBlocks::LeadImageSelect.expects(:new).with(page.images, default_lead_image: img, placeholder_image_url:).returns(block)
    assert_equal block, factory.build("integer", "lead_image_select")
  end

  test "it filters out svg images, in the lead image block" do
    page = StandardEdition.new
    images = [create(:image, :svg), create(:image)]
    page.images = images

    factory = ConfigurableContentBlocks::Factory.new(page)
    block = mock("ConfigurableContentBlocks::LeadImageSelect")

    ConfigurableContentBlocks::LeadImageSelect.expects(:new).with([images.last], anything, anything).returns(block)
    factory.build("integer", "lead_image_select")
  end

  test "it filters out images that require cropping, in the image blocks" do
    bitmap_image_that_requires_crop = create(:image)
    bitmap_image_that_requires_crop.image_data.stubs(:requires_crop?).returns(true)
    bitmap_image_that_does_not_requires_crop = create(:image)
    bitmap_image_that_does_not_requires_crop.image_data.stubs(:requires_crop?).returns(false)
    svg_image = create(:image, :svg)
    page = StandardEdition.new
    page.images = [bitmap_image_that_requires_crop, bitmap_image_that_does_not_requires_crop, svg_image]

    factory = ConfigurableContentBlocks::Factory.new(page)
    block = mock("ConfigurableContentBlocks::LeadImageSelect")

    ConfigurableContentBlocks::ImageSelect.expects(:new).with([bitmap_image_that_does_not_requires_crop, svg_image]).returns(block)
    factory.build("integer", "image_select")

    ConfigurableContentBlocks::LeadImageSelect.expects(:new).with([bitmap_image_that_does_not_requires_crop], anything, anything).returns(block)
    factory.build("integer", "lead_image_select")
  end

  test "it can build a govspeak string block, with images and attachments" do
    test_type_with_images_and_attachments =
      build_configurable_document_type(
        "test_type_with_images_and_attachments", {
          "settings" => {
            "images_enabled" => true,
            "file_attachments_enabled" => true,
          },
        }
      )

    ConfigurableDocumentType.setup_test_types(test_type_with_images_and_attachments)
    page = StandardEdition.new(configurable_document_type: "test_type_with_images_and_attachments")
    page.images = [build(:image)]
    page.attachments = [build(:file_attachment)]
    factory = ConfigurableContentBlocks::Factory.new(page)
    block = mock("ConfigurableContentBlocks::Govspeak")
    ConfigurableContentBlocks::Govspeak.expects(:new).with(page.images, page.attachments).returns(block)
    assert_equal block, factory.build("string", "govspeak")
  end
end
