require 'test_helper'

module Whitehall
  class UrlMakerTest < ActiveSupport::TestCase
    test 'default url options can be set at create time' do
      maker = Whitehall::UrlMaker.new(host: 'yahoo.com', protocol: 'ftp')
      assert_equal 'ftp://yahoo.com/government/get-involved/take-part/woo', maker.take_part_page_url('woo')
    end

    test 'default url options set on an instance do not interfere with other instances' do
      with_defaults = Whitehall::UrlMaker.new(host: 'yahoo.com', protocol: 'ftp')
      without_defaults = Whitehall::UrlMaker.new(host: 'meh.com', protocol: 'gopher')
      refute_equal with_defaults.get_involved_url, without_defaults.get_involved_url
    end

    test 'default url options are blank by default, and so host must be set when using _url helpers' do
      maker = Whitehall::UrlMaker.new
      assert_raises(ArgumentError) { maker.take_part_page_url('woo') }
      assert_equal 'http://gov.uk/government/get-involved/take-part/woo', maker.take_part_page_url('woo', host: 'gov.uk')
    end

    test 'includes all the relevant helpers for constructing urls' do
      # NOTE: not at all happy about this, but I don't want to write
      # tests to ensure all the routes are available
      assert Whitehall::UrlMaker.ancestors.include? Rails.application.routes.url_helpers
      assert Whitehall::UrlMaker.ancestors.include? PublicDocumentRoutesHelper
      assert Whitehall::UrlMaker.ancestors.include? MainstreamCategoryRoutesHelper
      assert Whitehall::UrlMaker.ancestors.include? FilterRoutesHelper
      assert Whitehall::UrlMaker.ancestors.include? Admin::EditionRoutesHelper
      assert Whitehall::UrlMaker.ancestors.include? LocalisedUrlPathHelper
    end

    test 'has an empty set of params (for the url helpers that need it)' do
      expected_params = {}
      assert_equal expected_params, Whitehall::UrlMaker.new.params
    end
  end
end
