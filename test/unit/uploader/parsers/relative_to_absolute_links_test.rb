# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require File.expand_path("../../../../fast_test_helper", __FILE__)
require 'whitehall/uploader/parsers/relative_to_absolute_links'

module Whitehall::Uploader::Parsers
  class RelativeToAbsoluteLinksTest < ActiveSupport::TestCase
    test 'converts relative links to absolute links' do
      assert_equal "[link](http://example.com/foo/bar)", RelativeToAbsoluteLinks.parse("[link](/foo/bar)", "http://example.com")
      assert_equal "[link](http://example.com/foo/bar?baz=qux)", RelativeToAbsoluteLinks.parse("[link](/foo/bar?baz=qux)", "http://example.com")
    end

    test 'ingores nil input' do
      assert_nil RelativeToAbsoluteLinks.parse(nil, "http://example.com")
    end
  end
end
