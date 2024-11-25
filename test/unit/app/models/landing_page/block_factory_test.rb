require "test_helper"

class BlockFactoryTest < ActiveSupport::TestCase
  test "#build builds a block" do
    block = LandingPage::BlockFactory.build({ "type" => "some-type" })
    assert_instance_of LandingPage::BaseBlock, block
  end

  test "#build_all builds blocks" do
    blocks = LandingPage::BlockFactory.build_all([{ "type" => "some-type" }, { "type" => "some-type" }])
    assert_equal 2, blocks.length
    assert_instance_of LandingPage::BaseBlock, blocks.first
    assert_instance_of LandingPage::BaseBlock, blocks.second
  end
end
