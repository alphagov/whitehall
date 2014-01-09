require "test_helper"

class DetailedGuidesControllerPropositionTest < ActionController::TestCase
  class TestController < DetailedGuidesController
    def test; render text: "ok"; end
  end

  tests TestController

  test "sets google analytics proposition to detailed-guidance for all actions" do
    with_routing do |map|
      map.draw do
        get '/test', to: 'detailed_guides_controller_proposition_test/test#test'
      end
      get :test
    end
    assert_equal "specialist", response.headers["X-Slimmer-Proposition"]
  end
end
