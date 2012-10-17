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

  test "all public facing requests are considered stale after 2 minutes" do
    with_routing_to_test_action do
      get :test
      assert response.headers["Cache-Control"].split(", ").include?("max-age=120")
    end
  end

  test "all public facing requests should use the inside government search" do
    with_routing_to_test_action do
      get :test
      assert_equal search_path, response.headers["X-Slimmer-Search-Path"]
    end
  end

  test "all public facing requests for any html content type should respond with html" do
    html_mime_types = ["text/html", "application/xhtml+xml"]

    html_mime_types.each do |type|
      with_routing_to_test_action do
        @request.env['HTTP_ACCEPT'] = type
        get :test
        assert_equal 200, response.status, "mime type #{type} should be acceptable"
        assert_equal Mime::HTML, response.content_type
      end
    end
  end

  test "all public facing requests for wap content should respond with html (considered better than nothing)" do
    with_routing_to_test_action do
      @request.env['HTTP_ACCEPT'] = "application/vnd.wap.xhtml+xml"
      get :test
      assert_equal 200, response.status, "mime type application/vnd.wap.xhtml+xml should be acceptable"
      assert_equal Mime::HTML, response.content_type
    end
  end

  test "all public facing requests for atom, json and content should respond with their respective types" do
    types = ["application/json", "application/xml", "application/atom+xml"]
    types.each do |type|
      with_routing_to_test_action do
        @request.env['HTTP_ACCEPT'] = type
        get :test
        assert_equal 200, response.status, "mime type #{type} should be acceptable"
        assert_equal type, response.content_type
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
