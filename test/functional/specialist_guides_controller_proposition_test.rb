require "test_helper"

class SpecialistGuidesControllerPropositionTest < ActionController::TestCase
  class TestController < SpecialistGuidesController
    def test; render text: "ok"; end
  end

  tests TestController

  test "sets google analytics proposition to specialist for all actions" do
    with_routing do |map|
      map.draw do
        match '/test', to: 'specialist_guides_controller_proposition_test/test#test'
      end
      @controller.stubs(:search_specialist_guides_path)
      get :test
    end
    assert_equal "specialist", response.headers["X-Slimmer-Proposition"]
  end
end
