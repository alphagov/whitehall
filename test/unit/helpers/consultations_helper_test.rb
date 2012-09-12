require 'test_helper'

class ConsultationsHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "#consultation_opening_phrase uses future tense if not yet open" do
    consultation = build(:consultation, opening_on: 2.days.from_now)
    assert consultation_opening_phrase(consultation).starts_with?("Opens on")
  end

  test "#consultation_opening_phrase uses past tense if already opened" do
    consultation = build(:consultation, opening_on: 2.days.ago)
    assert consultation_opening_phrase(consultation).starts_with?("Opened on ")
  end

  test "#consultation_opening_phrase includes long form date" do
    consultation = build(:consultation, opening_on: Date.new(2011, 10, 9))
    assert_match Regexp.new(Regexp.escape("9 October 2011")), consultation_opening_phrase(consultation)
  end

  test "#consultation_closing_phrase uses future tense if not yet closed" do
    consultation = build(:consultation, closing_on: 2.days.from_now)
    assert consultation_closing_phrase(consultation).starts_with?("Closes on")
  end

  test "#consultation_closing_phrase uses past tense if already opened" do
    consultation = build(:consultation, opening_on: Date.new(2010, 1, 1), closing_on: 2.days.ago)
    assert consultation_closing_phrase(consultation).starts_with?("Closed on ")
  end

  test "#consultation_closing_phrase includes long form date" do
    consultation = build(:consultation, opening_on: Date.new(2010, 1, 1), closing_on: Date.new(2011, 10, 9))
    assert_match Regexp.new(Regexp.escape("9 October 2011")), consultation_closing_phrase(consultation)
  end

  test "#consultation_time_remaining_phrase when not yet open" do
    consultation = build(:consultation, opening_on: Date.new(2011, 11, 25), closing_on: Date.new(2012, 2, 1))
    assert_equal "Opens in 14 days", consultation_time_remaining_phrase(consultation)
  end

  test "#consultation_time_remaining_phrase when open" do
    consultation = build(:consultation, opening_on: Date.new(2011, 11, 1), closing_on: Date.new(2011, 12, 1))
    assert_equal "Closes in 21 days", consultation_time_remaining_phrase(consultation)
  end

  test "#consultation_time_remaining_phrase when closed" do
    consultation = build(:consultation, opening_on: Date.new(2011, 7, 1), closing_on: Date.new(2011, 9, 1))
    assert_equal "", consultation_time_remaining_phrase(consultation)
  end

  test "#consultation_time_remaining_phrase when response published" do
    consultation = build(:consultation, opening_on: Date.new(2011, 5, 1), closing_on: Date.new(2011, 7, 1))
    response = consultation.create_response!
    response.attachments << build(:attachment)
    consultation.stubs(:published_consultation_response).returns(response)
    assert_equal "", consultation_time_remaining_phrase(consultation)
  end
end
