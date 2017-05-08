require "test_helper"

class ApplicationControllerSearchParametersTest < ActionController::TestCase
  class TestController < ApplicationController
    class Organisation < Struct.new(:slug, :"has_scoped_search?", :acronym); end

    def test_scoped
      org = Organisation.new("org1", true, "o1")
      set_slimmer_page_owner_header(org)
      render plain: "ok"
    end

    def test_unscoped
      org = Organisation.new("org2", false, "o2")
      set_slimmer_page_owner_header(org)
      render plain: "ok"
    end
  end

  tests TestController

  test "sets filter_organisations search parameter header for orgs with scoped search" do
    with_routing do |map|
      map.draw do
        get '/test_scoped', to: 'application_controller_search_parameters_test/test#test_scoped'
      end
      get :test_scoped
    end
    assert_equal %{{"filter_organisations":["org1"]}}, response.headers["X-Slimmer-Search-Parameters"]
  end

  test "doesn't set filter_organisations search parameter header for orgs without scoped search" do
    with_routing do |map|
      map.draw do
        get '/test_unscoped', to: 'application_controller_search_parameters_test/test#test_unscoped'
      end
      get :test_unscoped
    end
    assert_equal %{{"show_organisations_filter":true}}, response.headers["X-Slimmer-Search-Parameters"]
  end
end
