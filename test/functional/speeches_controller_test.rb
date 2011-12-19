require "test_helper"

class SpeechesControllerTest < ActionController::TestCase
  include DocumentControllerTestHelpers

  should_render_a_list_of :speeches
  should_show_related_policies_and_policy_areas_for :speech
  should_show_the_countries_associated_with :speech

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
end
