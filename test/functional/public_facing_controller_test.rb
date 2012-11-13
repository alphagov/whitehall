require "test_helper"

class PublicFacingControllerTest < ActionController::TestCase
  class TestController < PublicFacingController
    def test
      render text: 'ok'
    end
  end

  tests TestController

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
      assert_equal search_path, response.headers["X-Slimmer-Search-Path"]
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

  def with_routing_to_test_action(&block)
    with_routing do |map|
      map.draw do
        match '/search' => 'search#index'
        match '/test', to: 'public_facing_controller_test/test#test'
      end
      yield
    end
  end
end
