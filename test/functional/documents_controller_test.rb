# encoding: utf-8

require "test_helper"

class DocumentsControllerTest < ActionController::TestCase
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper
  default_url_options[:host] = 'test.host'

  setup do
    DocumentsController.any_instance.stubs(document_class: GenericEdition)
  end

  test "show responds with 'not found' and default cache control 'max-age' if no document (scheduled for publication or otherwise) exists" do
    user = login_as(:departmental_editor)
    edition = create(:draft_edition)

    get :show, id: edition.document

    assert_response :not_found
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age}")
  end

  view_test "show responds with 'Coming soon' page and shorter cache control 'max-age' if document is scheduled for publication" do
    user = login_as(:departmental_editor)
    edition = create(:draft_edition, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)
    edition.schedule_as(user, force: true)

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, id: edition.document
    end

    assert_select "h1", "Coming soon"
    assert_response :ok
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end

  view_test "show responds with 'Coming soon' page and default cache control 'max-age' if document is scheduled for publication far in the future" do
    user = login_as(:departmental_editor)
    edition = create(:draft_edition, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 10)
    edition.schedule_as(user, force: true)

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, id: edition.document
    end

    assert_select "h1", "Coming soon"
    assert_response :ok
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age}")
  end

  test "requests for documents in the default locale should redirect to the canonical URL that excludes the locale to avoid serving duplicate content on multiple URLs" do
    edition = build(:draft_edition)
    edition.save!
    edition.publish_as(create(:departmental_editor), force: true)

    get :show, id: edition.document, locale: 'en'

    assert_redirected_to public_document_path(edition)
  end

  view_test "should show links to other available translations of the edition" do
    edition = build(:draft_edition)
    with_locale(:es) do
      edition.assign_attributes(attributes_for(:draft_edition, title: 'spanish-title'))
    end
    edition.save!
    edition.publish_as(create(:departmental_editor), force: true)

    get :show, id: edition.document

    assert_select ".document-page-header .translations" do
      assert_select ".translation", text: "English"
      refute_select "a[href=?]", public_document_path(edition, locale: :en), text: 'English'
      assert_select "a[href=?]", public_document_path(edition, locale: :es), text: 'Español'
    end
  end

  view_test "should not show any links to translations when the edition is only available in one language" do
    edition = create(:draft_edition)
    edition.publish_as(create(:departmental_editor), force: true)

    get :show, id: edition.document

    refute_select ".document-page-header .translations"
  end
end
