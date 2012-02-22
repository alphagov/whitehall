require "test_helper"

class SpeechesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_render_a_list_of :speeches, :first_published_at
  should_show_related_policies_and_policy_topics_for :speech
  should_show_the_countries_associated_with :speech
  should_display_inline_images_for :speech
  should_not_display_lead_image_for :speech

  test "should display details about the speech" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, forename: "Theresa", surname: "May", image: fixture_file_upload('minister-of-funk.jpg'))
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may)
    speech_type = SpeechType::Transcript
    published_speech = create(:published_speech, speech_type: speech_type, role_appointment: theresa_may_appointment, delivered_on: Date.parse("2011-06-01"), location: "The Guidhall")

    get :show, id: published_speech.document_identity

    assert_select ".details .type", "Transcript"
    assert_select ".details .ministerial_role", "Theresa May (Secretary of State, Home Office)"
    assert_select ".details .delivered_on", "1 June 2011"
    assert_select ".details .location", "The Guidhall"
  end
end
