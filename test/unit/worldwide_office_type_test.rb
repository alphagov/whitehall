require "test_helper"

class WorldwideOfficeTypeTest < ActiveSupport::TestCase
  test "should provide slugs for every worldwide office type" do
    worldwide_office_types = WorldwideOfficeType.all
    assert_equal worldwide_office_types.length, worldwide_office_types.map(&:slug).compact.length
  end

  test "should be findable by slug" do
    worldwide_office_type = WorldwideOfficeType.find_by(id: 1)
    assert_equal worldwide_office_type, WorldwideOfficeType.find_by(slug: worldwide_office_type.slug)
  end

  test "should be fetchable in order" do
    assert_equal WorldwideOfficeType.all.map(&:listing_order).sort, WorldwideOfficeType.in_listing_order.map(&:listing_order)
  end

  test "should be fetchable by grouping (retaining order within group)" do
    in_groups = WorldwideOfficeType.by_grouping
    all_groups = WorldwideOfficeType.all.map(&:grouping).uniq.sort
    assert_equal all_groups, in_groups.keys.sort
    all_groups.each do |grouping|
      grouped_order = WorldwideOfficeType.all.select { |wot| wot.grouping == grouping }.map(&:listing_order).sort
      assert_equal grouped_order, in_groups[grouping].map(&:listing_order)
    end
  end
end
