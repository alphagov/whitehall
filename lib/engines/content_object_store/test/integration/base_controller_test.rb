require "test_helper"

class TestController < ContentObjectStore::BaseController
  def index
    render plain: "response", status: :ok
  end
end

class ContentObjectStore::BaseControllerTest < ActionDispatch::IntegrationTest
  setup do
    feature_flags.switch!(:content_object_store, true)
    login_as_admin

    @controller = TestController.new

    Rails.application.routes.draw do
      get "/test" => "test#index"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "sentry tags are set in a before filter" do
    mock = Minitest::Mock.new
    mock.expect(:call, nil, engine: "content_object_store")

    Sentry.stub(:set_tags, mock) do
      get "/test"
    end

    mock.verify
  end
end
