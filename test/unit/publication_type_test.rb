require "test_helper"

class PublicationTypeTest < ActiveSupport::TestCase
  test "should provide slugs for every publication type" do
    publication_types = PublicationType.all
    assert_equal publication_types.length, publication_types.map(&:slug).compact.length
  end

  test "should be findable by slug" do
    publication_type = PublicationType.find_by_id(1)
    assert_equal publication_type, PublicationType.find_by_slug(publication_type.slug)
  end

  test "should allow listing of all publication types by prevalence" do
    primary = [stub('primary publication type')]
    less_common = [stub('less_common publication type')]
    use_discouraged = [stub('use_discouraged publication type')]
    migration = [stub('migration publication type')]

    PublicationType.stubs(:primary).returns([primary])
    PublicationType.stubs(:less_common).returns([less_common])
    PublicationType.stubs(:use_discouraged).returns([use_discouraged])
    PublicationType.stubs(:migration).returns([migration])

    assert_equal [primary, less_common, use_discouraged, migration],
                 PublicationType.ordered_by_prevalence
  end
end
