require "test_helper"

class ConsultationResponsesControllerTest < ActionController::TestCase
  test 'show displays published consultations' do
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    get :show, consultation_id: consultation.document_identity
    assert_response :success
    assert_select ".title", text: published_consultation_response.title
    assert_select "a[href='#{consultation_path(consultation.document_identity)}']", text: consultation.title
  end
end
