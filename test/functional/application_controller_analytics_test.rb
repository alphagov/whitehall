require "test_helper"

class ApplicationControllerAnalyticsTest < ActionController::TestCase
  class TestController < ApplicationController
    class Organisation < Struct.new(:analytics_identifier); end

    def test_organisations
      orgs = [Organisation.new("D1"), Organisation.new("D2")]
      set_slimmer_organisations_header(orgs)
      render plain: "ok"
    end

    def test_format
      set_slimmer_format_header("format_name")
      render plain: "ok"
    end
  end

  tests TestController

  test "sets google analytics organisation header to the passed in org list" do
    with_routing do |map|
      map.draw do
        get '/test_organisations', to: 'application_controller_analytics_test/test#test_organisations'
      end
      get :test_organisations
    end
    assert_equal "<D1><D2>", response.headers["X-Slimmer-Organisations"]
  end

  test "sets format header for google analytics" do
    with_routing do |map|
      map.draw do
        get '/test_format', to: 'application_controller_analytics_test/test#test_format'
      end
      get :test_format
    end
    assert_equal "format_name", response.headers["X-Slimmer-Format"]
  end
end
