require "test_helper"

class SpeechesControllerTest < ActionController::TestCase

  should_render_a_list_of :speeches

  test 'show displays related published policies' do
    published_policy = create(:published_policy)
    speech = create(:published_speech, related_documents: [published_policy])
    get :show, id: speech.document_identity
    assert_select_object published_policy
  end

  test 'show doesn\'t display related unpublished policies' do
    draft_policy = create(:draft_policy)
    speech = create(:published_speech, related_documents: [draft_policy])
    get :show, id: speech.document_identity
    refute_select_object draft_policy
  end

  test 'show infers policy areas from published policies' do
    policy_area = create(:policy_area)
    published_policy = create(:published_policy, policy_areas: [policy_area])
    speech = create(:published_speech, related_documents: [published_policy])
    get :show, id: speech.document_identity
    assert_select_object policy_area
  end

  test "should display details about the speech" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, name: "Theresa May")
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may)
    published_speech = create(:published_speech_transcript, role_appointment: theresa_may_appointment, delivered_on: Date.parse("2011-06-01"), location: "The Guidhall")

    get :show, id: published_speech.document_identity

    assert_select ".details .type", "Transcript"
    assert_select ".details .ministerial_role", "Theresa May (Secretary of State, Home Office)"
    assert_select ".details .delivered_on", "June 1st, 2011"
    assert_select ".details .location", "The Guidhall"
  end

  test 'should display countries related to the speech' do
    mauritius = create(:country, name: 'Mauritius')
    published_speech = create(:published_speech, countries: [mauritius])

    get :show, id: published_speech.document_identity

    assert_select_object mauritius
  end
end
