require 'test_helper'

class Admin::ConsultationsHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "#consultation_opening_phrase uses future tense if not yet open" do
    consultation = build(:consultation, opening_at: 2.days.from_now)
    assert consultation_opening_phrase(consultation).starts_with?("Opens at")
  end

  test "#consultation_opening_phrase uses past tense if already opened" do
    consultation = build(:consultation, opening_at: 2.days.ago)
    assert consultation_opening_phrase(consultation).starts_with?("Opened at ")
  end

  test "#consultation_opening_phrase includes long form date" do
    consultation = build(:consultation, opening_at: Date.new(2011, 10, 9))
    assert_match Regexp.new(Regexp.escape("9 October 2011")), consultation_opening_phrase(consultation)
  end

  test "#consultation_closing_phrase uses future tense if not yet closed" do
    consultation = build(:consultation, closing_at: 2.days.from_now)
    assert consultation_closing_phrase(consultation).starts_with?("Closes at")
  end

  test "#consultation_closing_phrase uses past tense if already opened" do
    consultation = build(:consultation, opening_at: Date.new(2010, 1, 1), closing_at: 2.days.ago)
    assert consultation_closing_phrase(consultation).starts_with?("Closed at ")
  end

  test "#consultation_closing_phrase includes long form date" do
    consultation = build(:consultation, opening_at: Date.new(2010, 1, 1), closing_at: Date.new(2011, 10, 9))
    assert_match Regexp.new(Regexp.escape("9 October 2011")), consultation_closing_phrase(consultation)
  end
end
