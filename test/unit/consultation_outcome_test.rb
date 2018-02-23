require 'test_helper'

class ConsultationOutcomeTest < ActiveSupport::TestCase
  should_not_accept_footnotes_in :summary

  test '#access_limited_object returns the parent consultation' do
    consultation = FactoryBot.build(:consultation)
    outcome = FactoryBot.build(:consultation_outcome, consultation: consultation)

    assert_equal consultation, outcome.access_limited_object
  end

  test '#access_limited? delegates to the parent consultation' do
    consultation = FactoryBot.build(:consultation)
    consultation.stubs(:access_limited?).returns('access-limited')
    outcome = FactoryBot.build(:consultation_outcome, consultation: consultation)

    assert_equal 'access-limited', outcome.access_limited?
  end
end
