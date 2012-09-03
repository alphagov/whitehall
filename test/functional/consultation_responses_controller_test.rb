require "test_helper"

class ConsultationResponsesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_show_change_notes_on_action :consultation_response, :show do |consultation_response|
    get :show, consultation_id: consultation_response.consultation.document
  end

  test 'show displays the summary of the consultation response' do
    published_consultation_response = create(:published_consultation_response, summary: 'consultation-response-summary')
    get :show, consultation_id: published_consultation_response.consultation.document
    assert_select '.summary', 'consultation-response-summary'
  end

  test 'show displays published consultations' do
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    get :show, consultation_id: consultation.document
    assert_response :success
    assert_select ".page_title", text: published_consultation_response.title
    assert_select "a[href='#{consultation_path(consultation.document)}']", text: consultation.title
  end

  test "should link to the policies that the parent consultation is related to" do
    published_policy = create(:published_policy)
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    consultation.related_documents << published_policy.document
    get :show, consultation_id: consultation.document
    assert_select "#related-policies a[href='#{policy_path(published_policy.document)}']"
  end

  test "should display the topics that the parent consultation is related to" do
    topic = create(:topic)
    published_policy = create(:published_policy, topics: [topic])
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    consultation.related_documents << published_policy.document
    get :show, consultation_id: consultation.document
    assert_select ".topics a[href='#{topic_path(topic)}']"
  end

  test "should display the organisations that the parent consultation is related to" do
    organisation = create(:organisation)
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    consultation.organisations << organisation
    get :show, consultation_id: consultation.document
    assert_select "#document-organisations a[href='#{organisation_path(organisation)}']"
  end

  test "should display the ministers that the parent consultation is related to" do
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    ministerial_role = create(:ministerial_role)
    consultation.ministerial_roles << ministerial_role
    get :show, consultation_id: consultation.document
    assert_select "#document-ministers a[href='#{ministerial_role_path(ministerial_role)}']"
  end

  test "should display the national inapplicabilities that apply to the parent consultation" do
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    get :show, consultation_id: consultation.document
    refute_select "#inapplicable_nations"
  end
end
