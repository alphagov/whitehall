require "test_helper"

class ConsultationResponsesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'show displays published consultations' do
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    get :show, consultation_id: consultation.document_identity
    assert_response :success
    assert_select ".title", text: published_consultation_response.title
    assert_select "a[href='#{consultation_path(consultation.document_identity)}']", text: consultation.title
  end

  test "should link to the policies that the parent consultation is related to" do
    published_policy = create(:published_policy)
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    consultation.related_document_identities << published_policy.document_identity
    get :show, consultation_id: consultation.document_identity
    assert_select "#related-policies a[href='#{policy_path(published_policy.document_identity)}']"
  end

  test "should display the policy areas that the parent consultation is related to" do
    policy_area = create(:policy_area)
    published_policy = create(:published_policy, policy_areas: [policy_area])
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    consultation.related_document_identities << published_policy.document_identity
    get :show, consultation_id: consultation.document_identity
    assert_select ".meta a[href='#{policy_area_path(policy_area)}']"
  end

  test "should display the organisations that the parent consultation is related to" do
    organisation = create(:organisation)
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    consultation.organisations << organisation
    get :show, consultation_id: consultation.document_identity
    assert_select ".meta a[href='#{organisation_path(organisation)}']"
  end

  test "should display the ministers that the parent consultation is related to" do
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    ministerial_role = create(:ministerial_role)
    consultation.ministerial_roles << ministerial_role
    get :show, consultation_id: consultation.document_identity
    assert_select ".meta a[href='#{ministerial_role_path(ministerial_role)}']"
  end

  test "should display the national inapplicabilities that apply to the parent consultation" do
    published_consultation_response = create(:published_consultation_response)
    consultation = published_consultation_response.consultation
    get :show, consultation_id: consultation.document_identity
    assert_select "#inapplicable_nations", text: /applies to the whole of the uk/i
  end
end
