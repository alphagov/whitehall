require 'test_helper'

class ConsultationsHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "#consultation_css_class when an outcome exists" do
    consultation = Consultation.new
    consultation.build_outcome
    assert_equal 'consultation consultation-responded', consultation_css_class(consultation)
  end

  test "#consultation_css_class when closed" do
    consultation = Consultation.new
    consultation.stubs(:outcome_published?).returns(false)
    consultation.stubs(:closed?).returns(true)
    assert_equal 'consultation consultation-closed', consultation_css_class(consultation)
  end

  test "#consultation_css_class when open" do
    consultation = Consultation.new
    consultation.stubs(:outcome_published?).returns(false)
    consultation.stubs(:closed?).returns(false)
    consultation.stubs(:open?).returns(true)
    assert_equal 'consultation consultation-open', consultation_css_class(consultation)
  end

  test "#consultation_css_class when not-started" do
    consultation = Consultation.new
    consultation.stubs(:outcome_published?).returns(false)
    consultation.stubs(:closed?).returns(false)
    consultation.stubs(:open?).returns(false)
    assert_equal 'consultation ', consultation_css_class(consultation)
  end
end
