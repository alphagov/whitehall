# encoding: UTF-8
require "test_helper"

class Admin::ContactTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :departmental_editor
  end

  should_be_an_admin_controller

  test "create redirects to edit for the chosen language" do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation)

    post :create, organisation_id: organisation, contact_id: contact, translation_locale: "fr"

    assert_redirected_to edit_admin_organisation_contact_translation_path(organisation, contact, id: "fr")
  end

  view_test "edit indicates which language we are adding a translation for" do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation, title: "english-title")

    get :edit, organisation_id: organisation, contact_id: contact, id: "fr"

    assert_select "h1", text: "Edit 'Français (French)' translation for: english-title"
  end
end
