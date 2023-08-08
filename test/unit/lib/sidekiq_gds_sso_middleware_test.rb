require "test_helper"

class SidekiqGdsSsoMiddlewareTest < ActiveSupport::TestCase
  setup do
    @user = build(:user)
    @warden = mock("warden")
    @warden.stubs({ authenticated?: true, user: @user })
  end

  test "it will proxy a request to sidekiq web for an authenticated user with a 'Sidekiq Admin' permission" do
    @user.permissions = ["Sidekiq Admin"]
    env = { "warden" => @warden }

    Sidekiq::Web.expects(:call).with(env).returns([200, {}, %w[body]])
    SidekiqGdsSsoMiddleware.call(env)
  end

  test "it will return a 403 forbidden response for an authenticated user without 'Sidekiq Admin' permission" do
    @user.permissions = []

    status, _headers, body = SidekiqGdsSsoMiddleware.call({ "warden" => @warden })
    assert_equal(403, status)
    assert_equal(body, ["Forbidden - access requires the \"#{SidekiqGdsSsoMiddleware::SIDEKIQ_SIGNON_PERMISSION}\" permission"])
  end

  test "it runs warden.authenticate! when a user is not authenticated" do
    @warden.expects(:authenticate!)
    @warden.stubs(:authenticated?, false)

    SidekiqGdsSsoMiddleware.call({ "warden" => @warden })
  end

  test "it runs warden.authenticate! when a user is remotely signed out" do
    @warden.expects(:authenticate!)
    @user.remotely_signed_out = true

    SidekiqGdsSsoMiddleware.call({ "warden" => @warden })
  end
end
