require "test_helper"


class PublicFacingControllerTest < ActionController::TestCase
  class TestController < PublicFacingController
    enable_request_formats json: :json, js_or_atom: [:js, :atom]

    def test
      render text: 'ok'
    end

    def locale
      render text: I18n.locale.to_s
    end

    def json
      respond_to do |format|
        format.html { render text: 'html' }
        format.json { render text: '{}' }
      end
    end

    def js_or_atom
      respond_to do |format|
        format.html  { render text: 'html' }
        format.js    { render text: 'javascript' }
        format.atom  { render text: 'atom' }
      end
    end
  end

  class EnsureSegregationOfAcceptableFormatsBetweenControllersController < PublicFacingController
    enable_request_formats json: [:atom]
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

  test "HTML requests are allowed by default" do
    mime_types = ["text/html", "application/xhtml+xml"]

    mime_types.each do |type|
      with_routing_to_test_action do
        @request.env['HTTP_ACCEPT'] = type
        get :test
        assert_equal 200, response.status, "mime type #{type} should be acceptable"
        assert_equal Mime::HTML, response.content_type
      end
    end
  end

  test "non-HTML requests are rejected by default" do
    [:json, :xml, :atom].each do |format|
      get :test, format: format

      assert_response :not_acceptable
    end
  end

  test "additional formats can be explicitly enabled" do
    get :json
    assert_response :success
    assert_equal Mime::HTML, response.content_type
    assert_equal 'html', response.body

    get :json, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    assert_equal '{}', response.body

    get :json, format: :atom
    assert_response :not_acceptable
  end

  test "multiple formats can be enabled" do
    get :js_or_atom
    assert_response :success
    assert_equal Mime::HTML, response.content_type
    assert_equal 'html', response.body

    get :js_or_atom, format: :js
    assert_response :success
    assert_equal Mime::JS, response.content_type
    assert_equal 'javascript', response.body

    get :js_or_atom, format: :atom
    assert_response :success
    assert_equal Mime::ATOM, response.content_type
    assert_equal 'atom', response.body

    get :js_or_atom, format: :json
    assert_response :not_acceptable
  end

  test "returns an appropriate response for unrecognised/invalid request formats" do
    get :test, format: 'atom\\'
    assert_response :not_acceptable
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