require "test_helper"

class FatalityNoticeCasualtyTest < ActiveSupport::TestCase
  test "should not be valid without personal_details" do
    casualty = build(:fatality_notice_casualty, personal_details: nil)
    assert_not casualty.valid?
  end
end
