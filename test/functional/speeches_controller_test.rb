require "test_helper"

class SpeechesControllerTest < ActionController::TestCase

  test "should display who delivered the speech, and when & where it was delivered" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, name: "Theresa May")
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may)
    published_speech = create(:published_speech, role_appointment: theresa_may_appointment, delivered_on: Date.parse("2011-06-01"), location: "The Guidhall")

    get :show, id: published_speech.document_identity

    assert_select ".delivery .ministerial_role", "Theresa May (Secretary of State, Home Office)"
    assert_select ".delivery .date", "June 1st, 2011"
    assert_select ".delivery .location", "The Guidhall"
  end

end