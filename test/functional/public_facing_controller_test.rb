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
      response.headers["Cache-Control"].split(", ").include?("public")
    end
  end

  test "all public facing requests are considered stale after 2 minutes" do
    with_routing_to_test_action do
      get :test
      response.headers["Cache-Control"].split(", ").include?("max-age=120")
    end
  end

  def with_routing_to_test_action(&block)
    with_routing do |map|
      map.draw do
        match '/test', to: 'public_facing_controller_test/test#test'
      end
      yield
    end
  end
end