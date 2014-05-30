# encoding: utf-8

require "test_helper"

class DocumentsControllerTest < ActionController::TestCase
  include PublicDocumentRoutesHelper

  setup do
    DocumentsController.any_instance.stubs(document_class: Publication)
  end

  test "show responds with 'not found' and default cache control 'max-age' if no document (scheduled for publication or otherwise) exists" do
    login_as(:departmental_editor)
    edition = create(:draft_publication)

    get :show, id: edition.document

    assert_response :not_found
    assert_cache_control("max-age=#{5.minutes}")
  end

  test "show responds with 'unpublished' and default cache control 'max-age' if document has been unpublished" do
    login_as(:departmental_editor)
    edition = create(:unpublished_publication)

    get :show, id: edition.unpublishing.slug

    assert_response :success
    assert_template :unpublished
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age}")
  end

  test "show redirects to new location if the document has been unpublished and a redirect has been requested" do
    login_as(:departmental_editor)
    edition = create(:unpublished_publication)
    edition.unpublishing.update_attributes(redirect: true, alternative_url: Whitehall.url_maker.root_url)

    get :show, id: edition.unpublishing.slug

    assert_response :redirect
    assert_redirected_to edition.unpublishing.alternative_url
  end

  view_test "show responds with 'Coming soon' page and shorter cache control 'max-age' if document is scheduled for publication" do
    login_as(:departmental_editor)
    edition = create(:draft_publication, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)
    edition.perform_force_schedule

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, id: edition.document
    end

    assert_select "h1", "Coming soon"
    assert_response :ok
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age / 2}")
  end

  view_test "show responds with shorter cache control 'max-age' if document is scheduled for publication" do
    user = login_as(:departmental_editor)

    edition = create(:published_publication)
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
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age / 2}")
  end

  view_test "show responds with 'Coming soon' page and default cache control 'max-age' if document is scheduled for publication far in the future" do
    login_as(:departmental_editor)
    edition = create(:draft_publication, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 10)
    edition.perform_force_schedule

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, id: edition.document
    end

    assert_select "h1", "Coming soon"
    assert_response :ok
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age}")
  end

  test "show responds with 'not found' if document is deleted" do
    edition = create(:deleted_publication)

    get :show, id: edition.document

    assert_response :not_found
  end

  test "requests for documents in a locale it is translated into should respond successfully" do
    edition = create(:draft_publication, translated_into: 'fr')
    force_publish(edition)

    get :show, id: edition.document, locale: 'fr'

    assert_response :success
  end

  test "requests for documents in a locale it is not translated into should respond with a not_found" do
    edition = create(:draft_publication)
    force_publish(edition)

    get :show, id: edition.document, locale: 'fr'

    assert_response :not_found
  end
end
