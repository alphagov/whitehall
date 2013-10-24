# encoding: utf-8

require "test_helper"
require 'support/generic_edition'

class DocumentsControllerTest < ActionController::TestCase
  include PublicDocumentRoutesHelper

  setup do
    DocumentsController.any_instance.stubs(document_class: GenericEdition)
  end

  test "show responds with 'not found' and default cache control 'max-age' if no document (scheduled for publication or otherwise) exists" do
    user = login_as(:departmental_editor)
    edition = create(:draft_edition)

    get :show, id: edition.document

    assert_response :not_found
    assert_cache_control("max-age=#{5.minutes}")
  end

  test "show responds with 'unpublished' and default cache control 'max-age' if document has been unpublished" do
    user = login_as(:departmental_editor)
    edition = create(:unpublished_edition)

    get :show, id: edition.unpublishing.slug

    assert_response :success
    assert_template :unpublished
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age}")
  end

  test "show redirects to new location if the document has been unpublished and a redirect has been requested" do
    user = login_as(:departmental_editor)
    edition = create(:unpublished_edition)
    edition.unpublishing.update_attributes(redirect: true, alternative_url: "https://www.gov.uk/some-other-url")

    get :show, id: edition.unpublishing.slug

    assert_response :redirect
    assert_redirected_to edition.unpublishing.alternative_url
  end

  view_test "show responds with 'Coming soon' page and shorter cache control 'max-age' if document is scheduled for publication" do
    user = login_as(:departmental_editor)
    edition = create(:draft_edition, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)
    edition.perform_force_schedule

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, id: edition.document
    end

    assert_select "h1", "Coming soon"
    assert_response :ok
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end

  view_test "show responds with shorter cache control 'max-age' if document is scheduled for publication" do
    user = login_as(:departmental_editor)

    edition = create(:edition)
    edition.perform_force_publish
    new_draft = edition.create_draft(user)
    new_draft.title = "Second Title"
    new_draft.change_note = "change-note"
    new_draft.save_as(user)
    new_draft.scheduled_publication = Time.zone.now + Whitehall.default_cache_max_age * 2
    new_draft.perform_force_schedule

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, id: new_draft.document
    end

    assert_response :ok
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end

  view_test "show responds with 'Coming soon' page and default cache control 'max-age' if document is scheduled for publication far in the future" do
    user = login_as(:departmental_editor)
    edition = create(:draft_edition, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 10)
    edition.perform_force_schedule

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, id: edition.document
    end

    assert_select "h1", "Coming soon"
    assert_response :ok
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age}")
  end

  test "show responds with 'not found' if document is deleted" do
    edition = create(:deleted_edition)

    get :show, id: edition.document

    assert_response :not_found
  end

  test "requests for documents in a locale it is translated into should respond successfully" do
    edition = create(:draft_edition, translated_into: 'fr')
    edition.perform_force_publish

    get :show, id: edition.document, locale: 'fr'

    assert_response :success
  end

  test "requests for documents in a locale it is not translated into should respond with a not_found" do
    edition = create(:draft_edition)
    edition.perform_force_publish

    get :show, id: edition.document, locale: 'fr'

    assert_response :not_found
  end

  view_test "should show links to other available translations of the edition" do
    edition = build(:draft_edition)
    with_locale(:es) do
      edition.assign_attributes(attributes_for(:draft_edition, title: 'spanish-title'))
    end
    edition.save!
    edition.perform_force_publish

    get :show, id: edition.document

    assert_select ".translation", text: "English"
    refute_select "a[href=?]", public_document_path(edition, locale: :en), text: 'English'
    assert_select "a[href=?]", public_document_path(edition, locale: :es), text: 'Español'
  end

  view_test "should not show any links to translations when the edition is only available in one language" do
    edition = create(:draft_edition)
    edition.perform_force_publish

    get :show, id: edition.document

    refute_select ".translations"
  end
end
