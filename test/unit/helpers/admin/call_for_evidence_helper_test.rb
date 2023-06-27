require "test_helper"

class Admin::CallsForEvidenceHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "#call_for_evidence_opening_phrase uses future tense if not yet open" do
    call_for_evidence = build(:call_for_evidence, opening_at: 2.days.from_now)
    assert call_for_evidence_opening_phrase(call_for_evidence).starts_with?("Opens at")
  end

  test "#call_for_evidence_opening_phrase uses past tense if already opened" do
    call_for_evidence = build(:call_for_evidence, opening_at: 2.days.ago)
    assert call_for_evidence_opening_phrase(call_for_evidence).starts_with?("Opened at ")
  end

  test "#call_for_evidence_opening_phrase includes long form date" do
    call_for_evidence = build(:call_for_evidence, opening_at: Date.new(2011, 10, 9))
    assert_match Regexp.new(Regexp.escape("9 October 2011")), call_for_evidence_opening_phrase(call_for_evidence)
  end

  test "#call_for_evidence_closing_phrase uses future tense if not yet closed" do
    call_for_evidence = build(:call_for_evidence, closing_at: 2.days.from_now)
    assert call_for_evidence_closing_phrase(call_for_evidence).starts_with?("Closes at")
  end

  test "#call_for_evidence_closing_phrase uses past tense if already opened" do
    call_for_evidence = build(:call_for_evidence, opening_at: Date.new(2010, 1, 1), closing_at: 2.days.ago)
    assert call_for_evidence_closing_phrase(call_for_evidence).starts_with?("Closed at ")
  end

  test "#call_for_evidence_closing_phrase includes long form date" do
    call_for_evidence = build(:call_for_evidence, opening_at: Date.new(2010, 1, 1), closing_at: Date.new(2011, 10, 9))
    assert_match Regexp.new(Regexp.escape("9 October 2011")), call_for_evidence_closing_phrase(call_for_evidence)
  end
end
