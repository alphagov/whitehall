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

    test 'host can be set when using _url helpers' do
      maker = Whitehall::UrlMaker.new
      assert_equal 'http://gov.uk/government/get-involved/take-part/woo', maker.take_part_page_url('woo', host: 'gov.uk')
    end

    test 'the default format can be overridden for a localised resource' do
      maker = Whitehall::UrlMaker.new(host: 'gov.uk', format: 'atom')
      role  = create(:ministerial_role)

      assert_equal "http://gov.uk/government/ministers/#{role.slug}.atom", maker.url_for(role)
    end

    test 'the default format can be overridden for a non-localised resource' do
      maker = Whitehall::UrlMaker.new(host: 'gov.uk', format: 'atom')
      topic = create(:topic)

      assert_equal "http://gov.uk/government/topics/#{topic.slug}.atom", maker.url_for(topic)
    end
  end
end
