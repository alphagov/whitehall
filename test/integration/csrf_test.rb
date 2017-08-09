require 'test_helper'

class CsrfTest < ActionController::TestCase
  class TestAdminController < Admin::BaseController
    def create
      render plain: 'OK'
    end
  end
  tests TestAdminController

  setup do
    ActionController::Base.allow_forgery_protection = true
    login_as_admin
  end

  teardown do
    ActionController::Base.allow_forgery_protection = false
  end

  test "raises an InvalidAuthenticityToken exception without a valid CSRF token" do
    with_test_routes do
      assert_raises ActionController::InvalidAuthenticityToken do
        post :create
      end
    end
  end

  test "does not raise an exception with a valid CSRF token" do
    with_test_routes do
      session["_csrf_token"] = SecureRandom.base64(32)
      post :create, params: { authenticity_token: session["_csrf_token"] }
    end
  end

  def with_test_routes(&block)
    with_routing do |map|
      map.draw do
        post '/post_csrf', params: { to: 'csrf_test/test_admin#create' }
      end
      yield block
    end
  end
end
