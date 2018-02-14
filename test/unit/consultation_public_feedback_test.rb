require 'test_helper'

class ConsultationPublicFeedbackTest < ActiveSupport::TestCase
  should_not_accept_footnotes_in :summary

  test '#access_limited_object returns the parent consultation' do
    consultation = FactoryBot.build(:consultation)
    public_feedback = FactoryBot.build(:consultation_public_feedback, consultation: consultation)

    assert_equal consultation, public_feedback.access_limited_object
  end

  test '#access_limited? delegates to the parent consultation' do
    consultation = FactoryBot.build(:consultation)
    consultation.stubs(:access_limited?).returns('access-limited')
    public_feedback = FactoryBot.build(:consultation_public_feedback, consultation: consultation)

    assert_equal 'access-limited', public_feedback.access_limited?
  end
end
