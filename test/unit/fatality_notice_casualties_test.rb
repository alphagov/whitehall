require "test_helper"

class FatalityNoticeCasualtiesTest < ActiveSupport::TestCase
  test "should not be valid without personal_details" do
    casualty = build(:fatality_notice_casualty, personal_details: nil)
    refute casualty.valid?
  end
end
