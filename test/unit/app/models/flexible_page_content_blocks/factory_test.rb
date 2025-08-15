require "test_helper"
class FlexiblePageContentBlocks::FactoryTest < ActiveSupport::TestCase
  test "it raises an error if the block type does not exist" do
    page = FlexiblePage.new
    error = assert_raises do
      FlexiblePageContentBlocks::Factory.new(page).build("missing", "format")
    end
    assert_equal "No block is defined for the missing type format format", error.message
  end

  test "it raises an error if the block format does not exist" do
    page = FlexiblePage.new
    error = assert_raises do
      FlexiblePageContentBlocks::Factory.new(page).build("string", "missing")
    end
    assert_equal "No block is defined for the string type missing format", error.message
  end

  test "it can build a default object block" do
    page = FlexiblePage.new
    factory = FlexiblePageContentBlocks::Factory.new(page)
    block = mock("FlexiblePageContentBlocks::DefaultObject")
    FlexiblePageContentBlocks::DefaultObject.expects(:new).with(factory).returns(block)
    assert_equal block, factory.build("object")
  end

  test "it can build a default string block" do
    page = FlexiblePage.new
    factory = FlexiblePageContentBlocks::Factory.new(page)
    block = mock("FlexiblePageContentBlocks::DefaultString")
    FlexiblePageContentBlocks::DefaultString.expects(:new).returns(block)
    assert_equal block, factory.build("string")
  end

  test "it can build an image select string block" do
    page = FlexiblePage.new
    page.images = [build(:image)]
    factory = FlexiblePageContentBlocks::Factory.new(page)
    block = mock("FlexiblePageContentBlocks::ImageSelect")
    FlexiblePageContentBlocks::ImageSelect.expects(:new).with(page.images).returns(block)
    assert_equal block, factory.build("string", "image_select")
  end

  test "it can build a govspeak string block" do
    page = FlexiblePage.new
    page.images = [build(:image)]
    factory = FlexiblePageContentBlocks::Factory.new(page)
    block = mock("FlexiblePageContentBlocks::Govspeak")
    FlexiblePageContentBlocks::Govspeak.expects(:new).with(page.images).returns(block)
    assert_equal block, factory.build("string", "govspeak")
  end
end
