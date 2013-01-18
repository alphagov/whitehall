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

  test "#consultation_response_published_phrase uses future tense if publish date is in future" do
    response = stub('Response', published_on_or_default: 2.days.from_now, published?: true)
    assert consultation_response_published_phrase(response).starts_with?("Publishing response on")
  end

  test "#consultation_response_published_phrase uses past tense if publish date is in past" do
    response = stub('Response', published_on_or_default: 2.days.ago, published?: true)
    assert consultation_response_published_phrase(response).starts_with?("Published response on")
  end

  test "#consultation_response_published_phrase includes long form date" do
    response = stub('Response', published_on_or_default: Date.new(2012, 12, 12), published?: true)
    assert_match Regexp.new(Regexp.escape("12 December 2012")), consultation_response_published_phrase(response)
  end

  test "#consultation_response_published_phrase shows not yet published if not published yet" do
    response = stub('Response', published_on_or_default: nil, published?: false)
    assert_equal "Not yet published", consultation_response_published_phrase(response)
  end

  test "#consultation_css_class when responded" do
    consultation = Consultation.new
    consultation.stubs(:response_published?).returns(true)
    assert_equal 'consultation consultation-responded', consultation_css_class(consultation)
  end

  test "#consultation_css_class when closed" do
    consultation = Consultation.new
    consultation.stubs(:response_published?).returns(false)
    consultation.stubs(:closed?).returns(true)
    assert_equal 'consultation consultation-closed', consultation_css_class(consultation)
  end

  test "#consultation_css_class when open" do
    consultation = Consultation.new
    consultation.stubs(:response_published?).returns(false)
    consultation.stubs(:closed?).returns(false)
    consultation.stubs(:open?).returns(true)
    assert_equal 'consultation consultation-open', consultation_css_class(consultation)
  end

  test "#consultation_css_class when not-started" do
    consultation = Consultation.new
    consultation.stubs(:response_published?).returns(false)
    consultation.stubs(:closed?).returns(false)
    consultation.stubs(:open?).returns(false)
    assert_equal 'consultation ', consultation_css_class(consultation)
  end
end
