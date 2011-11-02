require "test_helper"

class ConsultationTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    consultation = build(:consultation)
    assert consultation.valid?
  end

  test "should not be valid without an opening on date" do
    consultation = build(:consultation, opening_on: nil)
    refute consultation.valid?
  end

  test "should not be valid without a closing on date" do
    consultation = build(:consultation, closing_on: nil)
    refute consultation.valid?
  end

  test "should not be valid if the opening date is after the closing date" do
    consultation = build(:consultation, opening_on: 1.day.ago, closing_on: 2.days.ago)
    refute consultation.valid?
  end

  test "allows attachment" do
    assert build(:consultation).allows_attachments?
  end

  test "should build a draft copy of the existing consultation with inapplicable nations" do
    published_consultation = create(:published_consultation, inapplicable_nations: [Nation.wales, Nation.scotland])

    draft_consultation = published_consultation.create_draft(create(:policy_writer))

    assert_equal published_consultation.inapplicable_nations, draft_consultation.inapplicable_nations
  end
end