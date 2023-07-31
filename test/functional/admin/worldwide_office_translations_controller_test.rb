require "test_helper"

class Admin::WorldwideOfficeTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as(:writer)
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
      assert_select  ".govuk-button-group .govuk-link[href='#{admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation)}']"
    end
  end
end
