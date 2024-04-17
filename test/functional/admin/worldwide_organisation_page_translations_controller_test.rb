require "test_helper"

class Admin::WorldwideOrganisationPageTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as(:writer)
    @worldwide_organisation = create(:editionable_worldwide_organisation, translated_into: %i[fr es])
  end

  should_be_an_admin_controller

  view_test "index shows a form to create missing translations" do
    page = create(:worldwide_organisation_page, edition: @worldwide_organisation)

    get :index, params: { editionable_worldwide_organisation_id: @worldwide_organisation, page_id: page }

    translations_path = admin_editionable_worldwide_organisation_page_translations_path(@worldwide_organisation, page)
    assert_select "form[action=?]", translations_path do
      assert_select "select[name=translation_locale]" do
        assert_select "option", count: 2
        assert_select "option[value=fr]", text: "Français (French)"
        assert_select "option[value=es]", text: "Español (Spanish)"
      end

      assert_select ".govuk-button-group .govuk-button", text: "Next"
      assert_select ".govuk-button-group .govuk-link[href='#{admin_editionable_worldwide_organisation_pages_path(@worldwide_organisation)}']"
    end
  end

  view_test "edit presents a form to update an existing translation" do
    page = create(:worldwide_organisation_page,
                  edition: @worldwide_organisation,
                  translated_into: [:fr])
    french_translation = page.translations.find_by(locale: :fr)

    get :edit, params: { editionable_worldwide_organisation_id: @worldwide_organisation, page_id: page, id: "fr" }

    translation_path = admin_editionable_worldwide_organisation_page_translation_path(@worldwide_organisation, page, "fr")
    assert_select "form[action=?]", translation_path do
      assert_select "textarea[name='page[summary]']", text: french_translation.summary
      assert_select "textarea[name='page[body]']", text: french_translation.body

      assert_select ".govuk-button-group .govuk-button", text: "Save"
    end
  end

  view_test "edit presents a form respecting the RTL value of the language" do
    page = create(:worldwide_organisation_page,
                  edition: @worldwide_organisation,
                  translated_into: [:ar])

    get :edit, params: { editionable_worldwide_organisation_id: @worldwide_organisation, page_id: page, id: "ar" }

    assert_select "form" do
      assert_select "textarea[name='page[summary]'][dir='rtl']"
      assert_select "textarea[name='page[body]'][dir='rtl']"
    end
  end

  view_test "update updates translation and redirects back to the index" do
    page = create(:worldwide_organisation_page, edition: @worldwide_organisation)

    put :update, params: { editionable_worldwide_organisation_id: @worldwide_organisation,
                           page_id: page,
                           id: "fr",
                           page: {
                             summary: "translated-summary",
                             body: "translated-body",
                           } }

    with_locale :fr do
      assert_equal "translated-summary", page.reload.summary
      assert_equal "translated-body", page.body
    end

    assert_redirected_to admin_editionable_worldwide_organisation_pages_path(@worldwide_organisation)
  end

  test "update re-renders form if translation is invalid" do
    page = create(:worldwide_organisation_page, edition: @worldwide_organisation)

    put :update, params: { editionable_worldwide_organisation_id: @worldwide_organisation,
                           page_id: page,
                           id: "fr",
                           page: {
                             summary: "translated-summary",
                             body: "",
                           } }

    assert_not page.reload.available_in_locale?("fr")
    assert_template :edit
  end

  test "destroy removes translation and redirects to admin edition page" do
    page = create(:worldwide_organisation_page,
                  edition: @worldwide_organisation,
                  translated_into: [:fr])

    delete :destroy, params: { editionable_worldwide_organisation_id: @worldwide_organisation,
                               page_id: page,
                               id: "fr" }
    assert_not page.reload.translated_locales.include?(:fr)
    assert_redirected_to admin_editionable_worldwide_organisation_pages_path(@worldwide_organisation)
  end

  test "#destroy deletes the translation from the publishing API" do
    Sidekiq::Testing.inline! do
      page = create(:worldwide_organisation_page,
                    edition: @worldwide_organisation,
                    translated_into: [:fr])

      delete :destroy, params: { editionable_worldwide_organisation_id: @worldwide_organisation,
                                 page_id: page,
                                 id: "fr" }

      assert_publishing_api_discard_draft(page.content_id, locale: "fr")
    end
  end
end
