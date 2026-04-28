require "test_helper"

class BlockFactoryTest < ActiveSupport::TestCase
  test "#build builds a block" do
    images = []
    block = PlanForChangeLandingPage::BlockFactory.build({ "type" => "some-type" }, images)
    assert_instance_of PlanForChangeLandingPage::BaseBlock, block
  end

  test "#build builds hero blocks with content" do
    images = []
    config = {
      "type" => "hero",
      "image" => {},
      "hero_content" => { "blocks" => [{ "type" => "some-type" }] },
    }
    block = PlanForChangeLandingPage::BlockFactory.build(config, images)
    assert_instance_of PlanForChangeLandingPage::HeroBlock, block
  end

  test "#build builds hero blocks without content" do
    images = []
    config = {
      "type" => "hero",
      "image" => {},
    }
    block = PlanForChangeLandingPage::BlockFactory.build(config, images)
    assert_instance_of PlanForChangeLandingPage::HeroBlock, block
  end

  test "#build_all builds blocks" do
    images = []
    blocks = PlanForChangeLandingPage::BlockFactory.build_all([{ "type" => "some-type" }, { "type" => "some-type" }], images)
    assert_equal 2, blocks.length
    assert_instance_of PlanForChangeLandingPage::BaseBlock, blocks.first
    assert_instance_of PlanForChangeLandingPage::BaseBlock, blocks.second
  end
end
