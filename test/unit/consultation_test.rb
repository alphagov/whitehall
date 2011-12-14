require "test_helper"

class ConsultationTest < ActiveSupport::TestCase
  include DocumentBehaviour

  should_be_featurable :consultation

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

  test "should build a draft copy of the existing consultation with the featured flag retained" do
    consultation = create(:published_consultation, featured: true)
    draft_consultation = consultation.create_draft(create(:policy_writer))
    assert draft_consultation.featured?
  end

  test ".closed includes consultations closing in the past" do
    closed_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)

    assert_equal 1, Consultation.closed.count
    assert_equal closed_consultation, Consultation.closed.first
  end

  test ".closed excludes consultations closing in the future" do
    open_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.from_now)

    assert_equal 0, Consultation.closed.count
  end

  test ".open includes consultations closing in the future and opening in the past" do
    open_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.from_now)

    assert_equal 1, Consultation.open.count
    assert_equal open_consultation, Consultation.open.first
  end

  test ".open excludes consultations opening in the future" do
    upcoming_consultation = create(:consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)

    assert_equal 0, Consultation.open.count
  end

  test ".open excludes consultations closing in the past" do
    closed_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)

    assert_equal 0, Consultation.open.count
  end

  test ".upcoming includes consultations opening in the future" do
    upcoming_consultation = create(:consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)

    assert_equal 1, Consultation.upcoming.count
    assert_equal upcoming_consultation, Consultation.upcoming.first
  end

  test ".upcoming excludes consultations opening in the past" do
    open_consultation = create(:consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    closed_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)

    assert_equal 0, Consultation.upcoming.count
  end
end