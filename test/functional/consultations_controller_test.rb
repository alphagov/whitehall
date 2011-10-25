require "test_helper"

class ConsultationsControllerTest < ActionController::TestCase
  test 'show displays published consultations' do
    published_consultation = create(:published_consultation)
    get :show, id: published_consultation.document_identity
    assert_response :success
  end

  test 'show displays consultation opening date' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2011, 10, 10))
    get :show, id: published_consultation.document_identity
    assert_select '.opening_on', text: 'Opened on October 10th, 2011'
  end

  test 'show displays consultation closing date' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2010, 1, 1), closing_on: Date.new(2011, 01, 01))
    get :show, id: published_consultation.document_identity
    assert_select '.closing_on', text: 'Closed on January 1st, 2011'
  end

  test 'show displays consultation attachment' do
    consultation = create(:published_consultation, attachment: create(:attachment))
    get :show, id: consultation.document_identity
    assert_select '.attachment a', text: consultation.attachment.filename
  end
end
