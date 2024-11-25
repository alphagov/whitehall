require "test_helper"

class BaseBlockTest < ActiveSupport::TestCase
  test "valid when given correct params" do
    subject = LandingPage::BaseBlock.new("type" => "some-type")
    assert subject.valid?
  end

  test "invalid when missing type" do
    subject = LandingPage::BaseBlock.new({})
    assert subject.invalid?
    assert_equal ["Type can't be blank"], subject.errors.to_a
  end
end
