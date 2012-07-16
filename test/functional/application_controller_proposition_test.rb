require "test_helper"

class ApplicationControllerPropositionTest < ActionController::TestCase
  class TestController < ApplicationController
    def test; render text: "ok"; end
  end

  tests TestController

  test "sets google analytics proposition to government for all actions" do
    with_routing do |map|
      map.draw do
        match '/test', to: 'application_controller_proposition_test/test#test'
      end
      get :test
    end
    assert_equal "government", response.headers["X-Slimmer-Proposition"]
  end
end
