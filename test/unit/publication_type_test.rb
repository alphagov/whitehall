require "test_helper"

class PublicationTypeTest < ActiveSupport::TestCase
  test "should provide slugs for every publication type" do
    publication_types = PublicationType.all
    assert_equal publication_types.length, publication_types.map(&:slug).compact.length
  end
end
