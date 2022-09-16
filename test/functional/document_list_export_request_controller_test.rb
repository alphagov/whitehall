require "test_helper"

class DocumentListExportRequestControllerTest < ActionController::TestCase
  setup do
    setup_fog_mock
  end

  teardown do
    Fog::Mock.reset
  end

  test "responds successfully if there is a valid file" do
    login_as :gds_editor

    document_type_slug = "asylum-support-decisions"
    export_id = "1234-5678"
    filename = "document_list_#{document_type_slug}_#{export_id}.csv"

    @directory.files.create(key: filename, body: "hello world") # rubocop:disable Rails/SaveBang

    get :show, params: { document_type_slug:, export_id: }
    assert_equal 200, response.status
    assert_equal "hello world", response.body
  end

  test "returns an error if there is no request" do
    login_as :gds_editor

    get :show, params: { document_type_slug: "asylum-support-decisions", export_id: "aaaa-bbbb" }
    assert_equal 404, response.status
  end

  test "returns an error if not logged in" do
    document_type_slug = "asylum-support-decisions"
    export_id = "1234-5678"
    filename = "document_list_#{document_type_slug}_#{export_id}.csv"

    @directory.files.create(key: filename, body: "hello world") # rubocop:disable Rails/SaveBang

    get :show, params: { document_type_slug:, export_id: }
    assert_equal 401, response.status
  end
end
