require "test_helper"

class PublicFacingControllerTest < ActionController::TestCase
  class TestController < PublicFacingController
    enable_request_formats json: :json, js_or_atom: [:js, :atom]

    def test
      render html: 'ok'
    end

    def locale
      render html: I18n.locale.to_s
    end

    def json
      respond_to do |format|
        format.html { render html: 'html' }
        format.json { render html: '{}' }
      end
    end

    def js_or_atom
      respond_to do |format|
        format.html  { render html: 'html' }
        format.js    { render html: 'javascript' }
        format.atom  { render html: 'atom' }
      end
    end

    def api_timeout
      raise GdsApi::TimedOutException
    end

    def api_bad_gateway
      raise GdsApi::HTTPErrorResponse.new(502, 'Bad Gateway')
    end

    def api_error
      raise GdsApi::HTTPErrorResponse.new(500, 'Something went wrong')
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
    with_routing_for_test_controller do
      get :test
      assert response.headers["Cache-Control"].split(", ").include?("public")
    end
  end

  test "all public facing requests are considered stale after default_cache_max_age" do
    with_routing_for_test_controller do
      get :test
      assert response.headers["Cache-Control"].split(", ").include?("max-age=#{Whitehall.default_cache_max_age.to_i}")
    end
  end

  test "HTML requests are allowed by default" do
    mime_types = ["text/html", "application/xhtml+xml"]

    mime_types.each do |type|
      with_routing_for_test_controller do
        @request.env['HTTP_ACCEPT'] = type
        get :test
        assert_equal 200, response.status, "mime type #{type} should be acceptable"
        assert_equal Mime[:html], response.content_type
      end
    end
  end

  test "non-HTML requests are rejected by default" do
    with_routing_for_test_controller do
      [:json, :xml, :atom].each do |format|
        get :test, format: format

        assert_response :not_acceptable
      end
    end
  end

  test "additional formats can be explicitly enabled" do
    with_routing_for_test_controller do
      get :json
      assert_response :success
      assert_equal Mime[:html], response.content_type
      assert_equal 'html', response.body

      get :json, format: :json
      assert_response :success
      assert_equal Mime[:json], response.content_type
      assert_equal '{}', response.body

      get :json, format: :atom
      assert_response :not_acceptable
    end
  end

  test "multiple formats can be enabled" do
    with_routing_for_test_controller do
      get :js_or_atom
      assert_response :success
      assert_equal Mime[:html], response.content_type
      assert_equal 'html', response.body

      get :js_or_atom, xhr: true
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
  end

  test "returns an appropriate response for unrecognised/invalid request formats" do
    with_routing_for_test_controller do
      get :test, format: 'atom\\'
      assert_response :not_acceptable
    end
  end

  test "all public facing requests without a locale should use the default locale" do
    with_routing_for_test_controller do
      I18n.default_locale = :dr
      get :locale
      assert_equal 'dr', response.body
    end
  end

  test "all public facing requests with a locale should use the given locale" do
    with_routing_for_test_controller do
      I18n.default_locale = :tr
      get :locale, params: { locale: 'fr' }
      assert_equal 'fr', response.body
    end
  end

  test "all public facing requests with a locale should reset locale back to its original value after completion" do
    with_routing_for_test_controller do
      I18n.locale = :dr
      get :locale, params: { locale: 'fr' }
      assert_equal :dr, I18n.locale
    end
  end

  test "public facing controllers catch GDS API timeouts and error responses and renders a 500 response" do
    with_routing_for_test_controller do
      get :api_timeout
      assert_response :internal_server_error
    end
  end

  test "public facing controllers catch 502 errors from GDS API and renders a 500 response" do
    with_routing_for_test_controller do
      get :api_bad_gateway
      assert_response :internal_server_error
    end
  end

  test "public facing controllers do not catch other GDS API errors" do
    with_routing_for_test_controller do
      assert_raise GdsApi::HTTPErrorResponse do
        get :api_error
      end
    end
  end

  test "public facing controllers explicitly set X-FRAME-OPTIONS header" do
    with_routing_for_test_controller do
      get :test
      assert response.headers["X-Frame-Options"] == 'ALLOWALL'
    end
  end

  def with_routing_for_test_controller(&block)
    with_routing do |map|
      map.draw do
        %w(test json js_or_atom locale api_timeout api_bad_gateway api_error).each do |action|
          get "/test/#{action}(.:format)", controller: 'public_facing_controller_test/test'
        end
      end
      yield
    end
  end
end
