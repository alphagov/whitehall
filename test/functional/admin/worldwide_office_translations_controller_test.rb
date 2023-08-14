require "test_helper"

class Admin::WorldwideOfficeTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user(:writer)
    @worldwide_organisation = create(:worldwide_organisation, translated_into: %i[fr es])
  end

  should_be_an_admin_controller

  view_test "index shows a form to create missing translations" do
    worldwide_office = create(:worldwide_office, worldwide_organisation: @worldwide_organisation)

    get :index, params: { worldwide_organisation_id: @worldwide_organisation, worldwide_office_id: worldwide_office }

    translations_path = admin_worldwide_organisation_worldwide_office_translations_path(@worldwide_organisation, worldwide_office)
    assert_select "form[action=?]", translations_path do
      assert_select "select[name=translation_locale]" do
        assert_select "option", count: 2
        assert_select "option[value=fr]", text: "Français (French)"
        assert_select "option[value=es]", text: "Español (Spanish)"
      end

      assert_select ".govuk-button-group .govuk-button", text: "Next"
      assert_select ".govuk-button-group .govuk-link[href='#{admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation)}']"
    end
  end

  view_test "edit presents a form to update an existing translation" do
    contact = create(
      :contact,
      translated_into: { fr: {
        title: "Département des barbes en France",
        comments: "De commentaire",
        recipient: "Premier ministre",
        street_address: "10 Downing Street",
        locality: "London",
        region: "City of London",
        email: "french.email@address",
        contact_form_url: "https://downing-street.fr",
      } },
    )
    worldwide_office = create(:worldwide_office,
                              worldwide_organisation: @worldwide_organisation,
                              contact:)

    french_translation = contact.translations.find_by(locale: :fr)

    get :edit, params: { worldwide_organisation_id: @worldwide_organisation, worldwide_office_id: worldwide_office, id: "fr" }

    translation_path = admin_worldwide_organisation_worldwide_office_translation_path(@worldwide_organisation, worldwide_office, "fr")
    assert_select "form[action=?]", translation_path do
      assert_select "input[type=text][name='contact[title]'][value='#{french_translation.title}']"
      assert_select "textarea[name='contact[comments]']", text: french_translation.comments
      assert_select "input[type=text][name='contact[recipient]'][value='#{french_translation.recipient}']"
      assert_select "textarea[name='contact[street_address]']", text: french_translation.street_address
      assert_select "input[type=text][name='contact[locality]'][value='#{french_translation.locality}']"
      assert_select "input[type=text][name='contact[region]'][value='#{french_translation.region}']"
      assert_select "input[type=text][name='contact[email]'][value='#{french_translation.email}']"
      assert_select "input[type=text][name='contact[contact_form_url]'][value='#{french_translation.contact_form_url}']"

      assert_select ".govuk-button-group .govuk-button", text: "Save"
    end
  end

  view_test "edit presents a form respecting the RTL value of the language" do
    worldwide_organisation = create(:worldwide_organisation, translated_into: %i[ar])
    worldwide_office = create(:worldwide_office, worldwide_organisation:)

    get :edit, params: { worldwide_organisation_id: worldwide_organisation, worldwide_office_id: worldwide_office, id: "ar" }

    assert_select "form" do
      assert_select "input[type=text][name='contact[title]'][dir='rtl']"
    end
  end

  view_test "update updates translation and redirects back to the index" do
    worldwide_office = create(:worldwide_office, worldwide_organisation: @worldwide_organisation)

    put :update, params: { worldwide_organisation_id: @worldwide_organisation,
                           worldwide_office_id: worldwide_office,
                           id: "fr",
                           contact: {
                             title: "Département des barbes en France",
                           } }

    with_locale :fr do
      assert_equal "Département des barbes en France", worldwide_office.reload.title
    end

    assert_redirected_to admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation)
  end

  test "update re-renders form if translation is invalid" do
    worldwide_office = create(:worldwide_office, worldwide_organisation: @worldwide_organisation)

    put :update, params: { worldwide_organisation_id: @worldwide_organisation,
                           worldwide_office_id: worldwide_office,
                           id: "fr",
                           contact: {
                             title: "",
                           } }

    assert_not worldwide_office.contact.available_in_locale?("fr")
    assert_template :edit
  end
end
