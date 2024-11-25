require "test_helper"

class ParentBlockTest < ActiveSupport::TestCase
  test "valid when given correct params" do
    subject = LandingPage::ParentBlock.new({
      "type" => "some-parent-type",
      "blocks" => [],
    }, [])
    assert subject.valid?
  end

  test "invalid when child blocks are invalid" do
    subject = LandingPage::ParentBlock.new({
      "type" => "some-parent-type",
      "blocks" => [{ "invalid" => "because I do not have a type" }],
    }, [])
    assert subject.invalid?
    assert_equal ["Type can't be blank"], subject.errors.to_a
  end
end
