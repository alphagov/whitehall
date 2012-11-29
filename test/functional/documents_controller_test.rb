require "test_helper"

class DocumentsControllerTest < ActionController::TestCase
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

  test "show responds with 'Coming soon' page and shorter cache control 'max-age' if document is scheduled for publication" do
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

  test "show responds with 'Coming soon' page and default cache control 'max-age' if document is scheduled for publication far in the future" do
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
end
