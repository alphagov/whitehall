require "test_helper"

module Whitehall
  class UrlMakerTest < ActiveSupport::TestCase
    test "default url options can be set at create time" do
      maker = Whitehall::UrlMaker.new(host: "yahoo.com", protocol: "ftp")
      assert_equal "ftp://yahoo.com/government/how-government-works", maker.how_government_works_url
    end

    test "default url options set on an instance do not interfere with other instances" do
      with_defaults = Whitehall::UrlMaker.new(host: "yahoo.com", protocol: "ftp")
      without_defaults = Whitehall::UrlMaker.new(host: "meh.com", protocol: "gopher")
      assert_not_equal with_defaults.how_government_works_url, without_defaults.how_government_works_url
    end

    test "host can be set when using _url helpers" do
      maker = Whitehall::UrlMaker.new
      assert_equal "http://gov.uk/government/how-government-works", maker.how_government_works_url(host: "gov.uk")
    end

    test "the default format can be overridden for a localised resource" do
      maker = Whitehall::UrlMaker.new(host: "gov.uk", format: "atom")
      worldwide_organisation = create(:worldwide_organisation)

      assert_equal "http://gov.uk/world/organisations/#{worldwide_organisation.slug}.atom", maker.url_for(worldwide_organisation)
    end

    test "the default format can be overridden for a non-localised resource" do
      maker = Whitehall::UrlMaker.new(host: "gov.uk", format: "atom")
      topical_event = create(:topical_event)

      assert_equal "http://gov.uk/government/topical-events/#{topical_event.slug}.atom", maker.url_for(topical_event)
    end
  end
end
