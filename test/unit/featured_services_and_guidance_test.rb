require "test_helper"

class FeaturedServicesAndGuidanceTest < ActiveSupport::TestCase
  test "should not be valid without a url" do
    link = build(:featured_services_and_guidance, url: nil)
    refute link.valid?
  end

  test "should not be valid without a title" do
    link = build(:featured_services_and_guidance, title: nil)
    refute link.valid?
  end

  test "should not be valid with a url that doesn't start with http" do
    link = build(:featured_services_and_guidance, url: "not a link")
    refute link.valid?
  end

  test 'only_the_initial_set retreives the first 10 by default' do
    11.times { create(:featured_services_and_guidance) }

    assert_equal 10, FeaturedServicesAndGuidance.only_the_initial_set.size
    assert_equal 3, FeaturedServicesAndGuidance.only_the_initial_set(3).size
  end
end
