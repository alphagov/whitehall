require "test_helper"

class BlockFactoryTest < ActiveSupport::TestCase
  test "#build builds a block" do
    images = []
    block = LandingPage::BlockFactory.build({ "type" => "some-type" }, images)
    assert_instance_of LandingPage::BaseBlock, block
  end

  test "#build builds hero blocks with content" do
    images = []
    config = {
      "type" => "hero",
      "image" => {},
      "hero_content" => { "blocks" => [{ "type" => "some-type" }] },
    }
    block = LandingPage::BlockFactory.build(config, images)
    assert_instance_of LandingPage::HeroBlock, block
  end

  test "#build builds hero blocks without content" do
    images = []
    config = {
      "type" => "hero",
      "image" => {},
    }
    block = LandingPage::BlockFactory.build(config, images)
    assert_instance_of LandingPage::HeroBlock, block
  end

  test "#build_all builds blocks" do
    images = []
    blocks = LandingPage::BlockFactory.build_all([{ "type" => "some-type" }, { "type" => "some-type" }], images)
    assert_equal 2, blocks.length
    assert_instance_of LandingPage::BaseBlock, blocks.first
    assert_instance_of LandingPage::BaseBlock, blocks.second
  end
end
