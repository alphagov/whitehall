require "test_helper"

class TestController < ContentBlockManager::BaseController
  def index
    render plain: "response", status: :ok
  end
end

class ContentBlockManager::BaseTest < ActionDispatch::IntegrationTest
  setup do
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
    mock.expect(:call, nil, engine: "content_block_manager")

    Sentry.stub(:set_tags, mock) do
      get "/test"
    end

    mock.verify
  end
end
