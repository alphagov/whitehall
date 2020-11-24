require "test_helper"

class BrexitContentNoticeValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = BrexitContentNoticeValidator.new
  end

  test "is valid when an edition has a show_brexit_no_deal_content_notice" do
    edition = create(:edition, show_brexit_no_deal_content_notice: true)
    @validator.validate(edition)
    assert_equal 0, edition.errors.count
  end

  test "is valid when an edition has a show_brexit_current_state_content_notice" do
    edition = create(:edition, show_brexit_current_state_content_notice: true)
    @validator.validate(edition)
    assert_equal 0, edition.errors.count
  end

  test "is invalid when an edition has both transition content notices" do
    edition = build(:edition, show_brexit_current_state_content_notice: true, show_brexit_no_deal_content_notice: true)
    message = "cannot have both show_brexit_no_deal_content_notice and show_brexit_current_state_content_notice"
    @validator.validate(edition)
    assert_equal 1, edition.errors.count
    assert_equal(
      message,
      edition.errors[:transition_content_notice].first,
    )
  end
end
