require "test_helper"

class Admin::ContactTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user(:departmental_editor)
  end

  should_be_an_admin_controller
  should_render_bootstrap_implementation_with_preview_next_release

  view_test "should be able to visit new index page for adding translations " do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation, title: "english-title")

    get :index, params: { organisation_id: organisation, contact_id: contact, id: "fr" }

    assert_select "h1", text: "New translation"
    assert_equal contact, assigns(:contact)
  end

  test "create redirects to edit for the chosen language" do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation)

    post :create, params: { organisation_id: organisation, contact_id: contact, translation_locale: "fr" }

    assert_redirected_to edit_admin_organisation_contact_translation_path(organisation, contact, id: "fr")
  end

  view_test "edit indicates which language we are adding a translation for" do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation, title: "english-title")

    get :edit, params: { organisation_id: organisation, contact_id: contact, id: "fr" }

    assert_select "h1", text: "Edit Français (French) translation"
  end

  view_test "edit displays translation boxes for contact numbers" do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation, title: "english-title")
    create(:contact_number, contact:, number: "123456789 english-number")

    get :edit, params: { organisation_id: organisation, contact_id: contact, id: "fr" }

    assert_select "input", value: "123456789 english-number"
  end

  test "update updates translation and redirects back to contacts list" do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation, title: "english-title")

    put :update,
        params: { organisation_id: organisation,
                  contact_id: contact,
                  id: "fr",
                  contact: {
                    title: "Afrolasie Bureau",
                    comments: "Enseigner aux gens comment infuser le thé",
                  } }

    contact.reload

    with_locale :fr do
      assert_equal "Afrolasie Bureau", contact.title
      assert_equal "Enseigner aux gens comment infuser le thé", contact.comments
    end

    assert_redirected_to admin_organisation_contacts_path(organisation)
  end

  test "GET :should be able to visit confirm_destroy page for a  translated contact" do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation, translated_into: [:fr])

    get :confirm_destroy, params: { organisation_id: organisation, contact_id: contact, id: "fr" }

    assert_response :success
    assert_equal contact, assigns(:contact)
  end

  test "destroy removes translation and redirects to contacts list" do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation, translated_into: [:fr])

    delete :destroy, params: { organisation_id: organisation, contact_id: contact, id: "fr" }

    contact.reload
    assert_not contact.translated_locales.include?(:fr)
    assert_redirected_to admin_organisation_contacts_path(organisation)
  end
end
