require "test_helper"


class PublicFacingControllerTest < ActionController::TestCase
  class TestController < PublicFacingController
    def test
      render text: 'ok'
    end

    def locale
      render text: I18n.locale.to_s
    end
  end

  tests TestController

  teardown do
    I18n.locale = :en
    I18n.default_locale = :en
  end

  test "all public facing requests are publically cacheable" do
    with_routing_to_test_action do
      get :test
      assert response.headers["Cache-Control"].split(", ").include?("public")
    end
  end

  test "all public facing requests are considered stale after default_cache_max_age" do
    with_routing_to_test_action do
      get :test
      assert response.headers["Cache-Control"].split(", ").include?("max-age=#{Whitehall.default_cache_max_age.to_i}")
    end
  end

  test "all public facing requests should use the inside government search" do
    with_routing_to_test_action do
      get :test
      assert_equal 'government', response.headers["X-Slimmer-Search-Index"]
    end
  end

  test "all public facing requests without a format parameter should respond with html" do
    mime_types = ["text/html", "application/xhtml+xml", "application/json", "application/xml", "application/atom+xml"]

    mime_types.each do |type|
      with_routing_to_test_action do
        @request.env['HTTP_ACCEPT'] = type
        get :test
        assert_equal 200, response.status, "mime type #{type} should be acceptable"
        assert_equal Mime::HTML, response.content_type
      end
    end
  end

  test "all public facing requests with a format parameter should respond with their respective format" do
    mime_types = {
      html: "text/html", json: "application/json", xml: "application/xml", atom: "application/atom+xml"
    }

    mime_types.each do |format, type|
      with_routing_to_test_action do
        @request.env['HTTP_ACCEPT'] = type
        get :test, format: format
        assert_equal 200, response.status, "mime type #{type} should be acceptable"
        assert_equal Mime::Type.lookup_by_extension(format), response.content_type
      end
    end
  end

  test "all public facing requests without a locale should use the default locale" do
    with_routing_to_test_action do
      I18n.default_locale = :default
      get :locale
      assert_equal 'default', response.body
    end
  end

  test "all public facing requests with a locale should use the given locale" do
    with_routing_to_test_action do
      I18n.default_locale = :default
      get :locale, locale: 'fr'
      assert_equal 'fr', response.body
    end
  end

  test "all public facing requests with a locale should reset locale back to its original value after completion" do
    with_routing_to_test_action do
      I18n.locale = :original
      get :locale, locale: 'fr'
      assert_equal :original, I18n.locale
    end
  end

  def with_routing_to_test_action(&block)
    with_routing do |map|
      map.draw do
        match '/search' => 'search#index'
        match '/test', to: 'public_facing_controller_test/test#test'
        match '/locale', to: 'public_facing_controller_test/test#locale'
      end
      yield
    end
  end
end