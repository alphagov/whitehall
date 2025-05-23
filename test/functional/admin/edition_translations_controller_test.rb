require "test_helper"

class Admin::EditionTranslationsControllerTest < ActionController::TestCase
  setup do
    @writer = login_as(:writer)
  end

  should_be_an_admin_controller

  view_test "new displays a form to create missing translations" do
    edition = create(:draft_edition)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :new, params: { edition_id: edition }

    assert_select "form[action=?]", admin_edition_translations_path(edition) do
      assert_select "select[name=translation_locale]"
      assert_select "button[type=submit]"
    end
  end

  view_test "new omits existing edition translations from create select" do
    edition = create(:draft_edition)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])
    with_locale(:es) { edition.update!(attributes_for("draft_edition")) }

    get :new, params: { edition_id: edition }

    assert_select "select[name=translation_locale]" do
      assert_select "option[value=es]", count: 0
    end
  end

  test "create redirects to edit for the chosen language" do
    edition = create(:edition)
    post :create, params: { edition_id: edition, translation_locale: "fr" }
    assert_redirected_to @controller.edit_admin_edition_translation_path(edition, id: "fr")
  end

  view_test "edit indicates which language we are adding a translation for" do
    edition = create(:edition, title: "english-title")

    get :edit, params: { edition_id: edition, id: "fr" }

    assert_select "h1", text: "Français (French) translation"
    assert_select ".govuk-caption-xl", text: "english-title"
  end

  view_test "edit presents a form to update an existing translation" do
    edition = create(:edition)
    with_locale(:fr) { edition.update!(title: "french-title", summary: "french-summary", body: "french-body") }

    get :edit, params: { edition_id: edition, id: "fr" }

    assert_select "form[action='#{@controller.admin_edition_translation_path(edition, 'fr')}']" do
      assert_select "input[type=text][name='edition[title]'][value='french-title']"
      assert_select "textarea[name='edition[summary]']", text: "french-summary"
      assert_select "textarea[name='edition[body]']", "french-body"

      assert_select "button[type=submit]"
      assert_select "a[href=?]", @controller.admin_edition_path(edition), text: "Cancel"
    end
  end

  view_test "edit shows the english values underneath the associated form fields" do
    edition = create(:edition)

    get :edit, params: { edition_id: edition, id: "fr" }

    assert_select ".app-c-translated-input__english-translation .govuk-details__text", text: edition.title
    assert_select ".app-c-translated-textarea__english-translation .govuk-details__text", text: edition.summary
    assert_select ".app-c-translated-textarea__english-translation .govuk-details__text", text: edition.body
  end

  view_test "edit shows the govspeak helper" do
    edition = create(:edition)

    get :edit, params: { edition_id: edition, id: "fr" }

    assert_select "#govspeak_tab"
  end

  view_test "edit shows history tab" do
    edition = create(:edition)
    create(:editorial_remark, edition:)

    get :edit, params: { edition_id: edition, id: "fr" }

    assert_select "#history_tab"
  end

  view_test "edit when translating corporate information pages does not allow title to be edited" do
    edition = create(:corporate_information_page)

    get :edit, params: { edition_id: edition, id: "cy" }

    refute_select "input#edition_title"
  end

  view_test "renders the govspeak help, history and fact checking tabs" do
    edition = create(:publication)

    fact_checking_view_component = Admin::Editions::FactCheckingTabComponent.new(edition:)
    Admin::Editions::FactCheckingTabComponent.expects(:new).with { |value|
      value[:edition].title == edition.title
    }.returns(fact_checking_view_component)

    get :edit, params: { edition_id: edition, id: "cy" }

    assert_select ".govuk-tabs__tab", text: "Help"
    assert_select ".govuk-tabs__tab", text: "History"
    assert_select ".govuk-tabs__tab", text: "Fact checking"
  end

  test "update creates a translation for an edition that's yet to be published, and redirect back to the edition admin page" do
    edition = create(:draft_edition)

    put :update,
        params: { edition_id: edition,
                  id: "fr",
                  edition: {
                    title: "translated-title",
                    summary: "translated-summary",
                    body: "translated-body",
                  } }

    edition.reload

    with_locale :fr do
      assert_equal "translated-title", edition.title
      assert_equal "translated-summary", edition.summary
      assert_equal "translated-body", edition.body
    end

    assert_redirected_to @controller.admin_edition_path(edition)
  end

  test "update creates a translation for a new draft of a previously published edition" do
    published_edition = create(:published_edition)
    draft_edition = published_edition.create_draft(@writer)

    put :update,
        params: { edition_id: draft_edition,
                  id: "fr",
                  edition: {
                    title: "translated-title",
                    summary: "translated-summary",
                    body: "translated-body",
                  } }

    draft_edition.reload

    with_locale :fr do
      assert_equal "translated-title", draft_edition.title
      assert_equal "translated-summary", draft_edition.summary
      assert_equal "translated-body", draft_edition.body
    end
  end

  test "update does not overwrite an existing manually added change note when adding a new translation" do
    edition = create(:draft_edition, change_note: "manually-added-change-note")

    put :update,
        params: { edition_id: edition,
                  id: "fr",
                  edition: {
                    title: "translated-title",
                    summary: "translated-summary",
                    body: "translated-body",
                  } }

    edition.reload

    assert_equal "manually-added-change-note", edition.change_note
  end

  view_test "update renders the form again, with errors, if the translation is invalid" do
    edition = create(:draft_edition)

    put :update,
        params: { edition_id: edition,
                  id: "fr",
                  edition: {
                    title: "",
                  } }

    assert_select ".govuk-error-summary"
  end

  view_test "#update puts the translation to the publishing API" do
    Sidekiq::Testing.inline! do
      edition = create(:draft_edition)

      put :update,
          params: { edition_id: edition,
                    id: "fr",
                    edition: {
                      title: "translated-title",
                      summary: "translated-summary",
                      body: "translated-body",
                    } }

      assert_publishing_api_put_content(
        edition.content_id,
        request_json_includes(
          title: "translated-title",
          description: "translated-summary",
          locale: "fr",
        ),
      )
    end
  end

  test "should limit access to translations of editions that aren't accessible to the current user" do
    protected_edition = create(:draft_publication, :access_limited)

    post :create, params: { edition_id: protected_edition.id, id: "en" }
    assert_response :forbidden

    get :edit, params: { edition_id: protected_edition.id, id: "en" }
    assert_response :forbidden

    put :update, params: { edition_id: protected_edition.id, id: "en" }
    assert_response :forbidden
  end

  test "#confirm_destroy returns a redirect with a flash message for a translation associated with a published edition" do
    edition = build(:published_edition)
    with_locale(:fr) { edition.update!(title: "french-title", summary: "french-summary", body: "french-body") }

    get :confirm_destroy, params: { edition_id: edition, id: "fr" }

    assert_redirected_to @controller.admin_edition_path(edition)
    assert_equal "You cannot modify a #{edition.state} #{edition.type.titleize}", flash[:alert]
  end

  test "destroy removes translation and redirects to admin edition page" do
    edition = create(:edition)
    with_locale(:fr) { edition.update!(title: "french-title", summary: "french-summary", body: "french-body") }

    delete :destroy, params: { edition_id: edition, id: "fr" }

    edition.reload
    assert_not edition.translated_locales.include?(:fr)
    assert_redirected_to @controller.admin_edition_path(edition)
  end

  test "#destroy deletes the translation from the publishing API" do
    Sidekiq::Testing.inline! do
      edition = create(:edition)
      with_locale(:fr) { edition.update!(title: "french-title", summary: "french-summary", body: "french-body") }

      delete :destroy, params: { edition_id: edition, id: "fr" }

      assert_publishing_api_discard_draft(edition.content_id, locale: "fr")
    end
  end

  test "#destroy returns a redirect with a flash message for a translation associated with a published edition" do
    edition = build(:published_edition)
    with_locale(:fr) { edition.update!(title: "french-title", summary: "french-summary", body: "french-body") }

    delete :destroy, params: { edition_id: edition, id: "fr" }

    assert_redirected_to @controller.admin_edition_path(edition)
    assert_equal "You cannot modify a #{edition.state} #{edition.type.titleize}", flash[:alert]
  end
end
