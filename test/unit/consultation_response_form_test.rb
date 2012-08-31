require 'test_helper'

class ConsultationResponseFormTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should be invalid without a title' do
    form = build(:consultation_response_form, title: nil)
    refute form.valid?
  end

  test 'should be invalid without a file' do
    form = build(:consultation_response_form, file: nil)
    refute form.valid?
  end
end
