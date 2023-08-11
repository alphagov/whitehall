require "test_helper"

class LegacyWorldwideOfficeTypeTest < ActiveSupport::TestCase
  test "should provide slugs for every worldwide office type" do
    worldwide_office_types = WorldwideOfficeType.all
    assert_equal worldwide_office_types.length, worldwide_office_types.map(&:slug).compact.length
  end

  test "should be findable by slug" do
    worldwide_office_type = WorldwideOfficeType.find_by_id(1)
    assert_equal worldwide_office_type, WorldwideOfficeType.find_by_slug(worldwide_office_type.slug)
  end

  test "should be fetchable in order" do
    assert_equal WorldwideOfficeType.all.map(&:listing_order).sort, WorldwideOfficeType.in_listing_order.map(&:listing_order)
  end

  test "should be fetchable by grouping (retaining order within group)" do
    in_groups = WorldwideOfficeType.legacy_by_grouping
    all_groups = WorldwideOfficeType.all.map(&:grouping).uniq.sort
    assert_equal all_groups, in_groups.keys.sort
    all_groups.each do |grouping|
      grouped_order = WorldwideOfficeType.all.select { |wot| wot.grouping == grouping }.map(&:listing_order).sort
      assert_equal grouped_order, in_groups[grouping].map(&:listing_order)
    end
  end

  test "#embassy_office? returns true for embassy office types" do
    WorldwideOfficeType::EMBASSY_OFFICE_TYPES.each do |office_type|
      assert office_type.embassy_office?
    end
  end

  test "#embassy_office? returns false for non-embassy office types" do
    (WorldwideOfficeType.all - WorldwideOfficeType::EMBASSY_OFFICE_TYPES).each do |office_type|
      assert_not office_type.embassy_office?
    end
  end
end
