# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require File.expand_path("../../../fast_test_helper", __FILE__)
require 'whitehall/publication_filter_option'

module Whitehall
  class PublicationFilterOptionTest < ActiveSupport::TestCase
    test "returns a list of options which have labels for publication type groupings" do
      assert PublicationFilterOption.all.respond_to?(:each)
      assert PublicationFilterOption.all.first.respond_to?(:label)
    end

    test "#slug returns a sluggified version" do
      assert_equal "policy-papers", PublicationFilterOption.new(label: "Policy papers").slug
    end

    test "finding by slug returns the slugged version" do
      option = PublicationFilterOption.create(label: "Test Filter Option")
      assert_equal option, PublicationFilterOption.find_by_slug("test-filter-option")
    end
  end
end
