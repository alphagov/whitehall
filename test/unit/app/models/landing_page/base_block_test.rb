require "test_helper"

class BaseBlockTest < ActiveSupport::TestCase
  test "valid when given correct params" do
    subject = LandingPage::BaseBlock.new({ "type" => "some-type" }, [])
    assert subject.valid?
  end

  test "invalid when missing type" do
    subject = LandingPage::BaseBlock.new({}, [])
    assert subject.invalid?
    assert_equal ["Type can't be blank"], subject.errors.to_a
  end

  test "raises error when presenting an invalid block to publishing api" do
    subject = LandingPage::BaseBlock.new({}, [])
    assert subject.invalid?
    assert_raises(StandardError, match: /cannot present invalid block to publishing api.*Type can't be blank/) { subject.present_for_publishing_api }
  end
end
