require "test_helper"

module Whitehall
  class UrlMakerTest < ActiveSupport::TestCase
    test "default url options can be set at create time" do
      maker = Whitehall::UrlMaker.new(host: "yahoo.com", protocol: "ftp")
      assert_equal "ftp://yahoo.com/government/ministers", maker.ministerial_roles_url
    end

    test "default url options set on an instance do not interfere with other instances" do
      with_defaults = Whitehall::UrlMaker.new(host: "yahoo.com", protocol: "ftp")
      without_defaults = Whitehall::UrlMaker.new(host: "meh.com", protocol: "gopher")
      assert_not_equal with_defaults.ministerial_roles_url, without_defaults.ministerial_roles_url
    end

    test "host can be set when using _url helpers" do
      maker = Whitehall::UrlMaker.new
      assert_equal "http://gov.uk/government/ministers", maker.ministerial_roles_url(host: "gov.uk")
    end

    test "the default format can be overridden for a localised resource" do
      maker = Whitehall::UrlMaker.new(host: "gov.uk", format: "atom")
      worldwide_organisation = create(:worldwide_organisation)

      assert_equal "http://gov.uk/world/organisations/#{worldwide_organisation.slug}.atom", maker.url_for(worldwide_organisation)
    end
  end
end
