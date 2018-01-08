# encoding: UTF-8

require 'test_helper'

class Admin::EditionTranslationsControllerTest < ActionController::TestCase
  setup do
    @writer = login_as(:writer)
  end

  should_be_an_admin_controller

  test 'create redirects to edit for the chosen language' do
    edition = create(:edition)
    post :create, params: { edition_id: edition, translation_locale: 'fr' }
    assert_redirected_to edit_admin_edition_translation_path(edition, id: 'fr')
  end

  view_test 'edit indicates which language we are adding a translation for' do
    edition = create(:edition, title: 'english-title')

    get :edit, params: { edition_id: edition, id: 'fr' }

    assert_select "h1", text: "Edit ‘Français (French)’ translation for: english-title"
  end

  view_test 'edit presents a form to update an existing translation' do
    edition = create(:edition)
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body') }

    get :edit, params: { edition_id: edition, id: 'fr' }

    assert_select "form[action='#{admin_edition_translation_path(edition, 'fr')}']" do
      assert_select "input[type=text][name='edition[title]'][value='french-title']"
      assert_select "textarea[name='edition[summary]']", text: 'french-summary'
      assert_select "textarea[name='edition[body]']", 'french-body'

      assert_select "input[type=submit][value=Save]"
      assert_select "a[href=?]", admin_edition_path(edition), text: 'cancel'
    end
  end

  view_test 'edit shows the english values underneath the associated form fields' do
    edition = create(:edition)

    get :edit, params: { edition_id: edition, id: 'fr' }

    assert_select '#english_title', text: "English: #{edition.title}"
    assert_select '#english_summary', text: "English: #{edition.summary}"
    assert_select '#english_body', text: "English: #{edition.body}"
  end

  view_test "edit shows the govspeak helper" do
    edition = create(:edition)

    get :edit, params: { edition_id: edition, id: 'fr' }

    assert_select '#govspeak_help'
  end

  view_test "edit shows editorial remarks" do
    edition = create(:edition)
    create(:editorial_remark, edition: edition)

    get :edit, params: { edition_id: edition, id: "fr" }

    assert_select "#notes"
  end

  view_test "edit when translating corporate information pages does not allow title to be edited" do
    edition = create(:corporate_information_page)

    get :edit, params: { edition_id: edition, id: "cy" }

    refute_select "input#edition_title"
  end

  test "update creates a translation for an edition that's yet to be published, and redirect back to the edition admin page" do
    edition = create(:draft_edition)

    put :update, params: { edition_id: edition, id: 'fr', edition: {
      title: 'translated-title',
      summary: 'translated-summary',
      body: 'translated-body'
    } }

    edition.reload

    with_locale :fr do
      assert_equal 'translated-title', edition.title
      assert_equal 'translated-summary', edition.summary
      assert_equal 'translated-body', edition.body
    end

    assert_redirected_to admin_edition_path(edition)
  end

  test "update creates a translation for a new draft of a previously published edition" do
    published_edition = create(:published_edition)
    draft_edition = published_edition.create_draft(@writer)

    put :update, params: { edition_id: draft_edition, id: 'fr', edition: {
      title: 'translated-title',
      summary: 'translated-summary',
      body: 'translated-body'
    } }

    draft_edition.reload

    with_locale :fr do
      assert_equal 'translated-title', draft_edition.title
      assert_equal 'translated-summary', draft_edition.summary
      assert_equal 'translated-body', draft_edition.body
    end
  end

  test "update does not overwrite an existing manually added change note when adding a new translation" do
    edition = create(:draft_edition, change_note: 'manually-added-change-note')

    put :update, params: { edition_id: edition, id: 'fr', edition: {
      title: 'translated-title',
      summary: 'translated-summary',
      body: 'translated-body'
    } }

    edition.reload

    assert_equal 'manually-added-change-note', edition.change_note
  end

  view_test 'update renders the form again, with errors, if the translation is invalid' do
    edition = create(:draft_edition)

    put :update, params: { edition_id: edition, id: 'fr', edition: {
      title: ''
    } }

    assert_select '.form-errors'
  end

  view_test "#update puts the translation to the publishing API" do
    edition = create(:draft_edition)

    put :update, params: { edition_id: edition, id: "fr", edition: {
      title: "translated-title",
      summary: "translated-summary",
      body: "translated-body",
    } }

    assert_publishing_api_put_content(
      edition.content_id,
      request_json_includes(
        title: "translated-title",
        description: "translated-summary",
        locale: "fr"
      )
    )
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

  test "destroy removes translation and redirects to admin edition page" do
    edition = create(:edition)
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body') }

    delete :destroy, params: { edition_id: edition, id: 'fr' }

    edition.reload
    refute edition.translated_locales.include?(:fr)
    assert_redirected_to admin_edition_path(edition)
  end

  test "#destroy deletes the translation from the publishing API" do
    edition = create(:edition)
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body') }

    delete :destroy, params: { edition_id: edition, id: 'fr' }

    assert_publishing_api_discard_draft(edition.content_id, locale: 'fr')
  end
end
