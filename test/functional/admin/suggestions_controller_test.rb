require "test_helper"

class Admin::SuggestionsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  test "should find worldwide and organisation contacts" do
    organisation = create(:organisation, acronym: "org-name")
    worldwide_organisation = create(:worldwide_organisation, name: "world-name")

    contact1 = create(:contact, contactable: organisation)
    contact2 = create(:contact_with_country)

    create(
      :worldwide_office,
      worldwide_organisation:,
      contact: contact2,
    )

    get :index, format: :json

    assert_equal [
      { id: contact1.id, title: contact1.title, summary: "org-name" },
      { id: contact2.id, title: contact2.title, summary: "world-name" },
    ],
                 assigns(:contacts)
  end
end
