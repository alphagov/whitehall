require "test_helper"
class BrokenLinksExportRequestControllerTest < ActionController::TestCase
  setup do
    setup_fog_mock
  end

  teardown do
    Fog::Mock.reset
  end

  test "responds successfully if there is a valid file" do
    login_as :gds_editor

    export_id = Time.zone.today.strftime
    filename = "broken-link-reports-#{export_id}.zip"

    @directory.files.create(key: filename, body: "hello world") # rubocop:disable Rails/SaveBang

    get :show, params: { export_id: }
    assert_equal 200, response.status
    assert_equal "hello world", response.body
  end

  test "returns an error if there is no request" do
    login_as :gds_editor

    get :show, params: { export_id: "1970-01-01" }
    assert_equal 404, response.status
  end

  test "returns an error if not logged in" do
    export_id = Time.zone.today.strftime
    filename = "broken-link-reports-#{export_id}.zip"

    @directory.files.create(key: filename, body: "hello world") # rubocop:disable Rails/SaveBang

    get :show, params: { export_id: }
    assert_equal 401, response.status
  end
end
