require 'test_helper'

class ConsultationsHelperTest < ActionView::TestCase
  test "#consultation_opening_phrase uses future tense if not yet open" do
    consultation = create(:consultation, opening_on: 2.days.from_now)
    assert consultation_opening_phrase(consultation).starts_with?("Opens on")
  end

  test "#consultation_opening_phrase uses past tense if already opened" do
    consultation = create(:consultation, opening_on: 2.days.ago)
    assert consultation_opening_phrase(consultation).starts_with?("Opened on ")
  end

  test "#consultation_opening_phrase includes long form date" do
    consultation = create(:consultation, opening_on: Date.new(2011, 10, 9))
    assert_equal "Opened on October 9th, 2011", consultation_opening_phrase(consultation)
  end

  test "#consultation_closing_phrase uses future tense if not yet closed" do
    consultation = create(:consultation, closing_on: 2.days.from_now)
    assert consultation_closing_phrase(consultation).starts_with?("Closes on")
  end

  test "#consultation_closing_phrase uses past tense if already opened" do
    consultation = create(:consultation, opening_on: Date.new(2010, 1, 1), closing_on: 2.days.ago)
    assert consultation_closing_phrase(consultation).starts_with?("Closed on ")
  end

  test "#consultation_closing_phrase includes long form date" do
    consultation = create(:consultation, opening_on: Date.new(2010, 1, 1), closing_on: Date.new(2011, 10, 9))
    assert_equal "Closed on October 9th, 2011", consultation_closing_phrase(consultation)
  end
end
