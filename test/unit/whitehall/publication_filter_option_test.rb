require 'test_helper'

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
      assert_equal PublicationFilterOption::OpenConsultation, PublicationFilterOption.find_by_slug("open-consultations")
    end

    test "edition_types is an empty array by default" do
      assert_equal [], PublicationFilterOption.new.edition_types
    end
  end
end
