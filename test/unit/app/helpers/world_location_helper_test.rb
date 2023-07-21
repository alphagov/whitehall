require "test_helper"

class WorldLocationHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL
  include WorldLocationHelper

  context "#sort" do
    test "sorts correctly where special characters are used anywhere other than the first character" do
      world_location_1 = create(:world_location, name: "Cow")
      world_location_2 = create(:world_location, name: "Côt")
      unsorted = [world_location_1, world_location_2]

      expected_order = [
        world_location_2,
        world_location_1,
      ]

      assert_equal expected_order, sort(unsorted)
    end

    test "sorts correctly where special characters are used as the first character" do
      world_location_1 = create(:world_location, name: "England")
      world_location_2 = create(:world_location, name: "Éire")
      unsorted = [world_location_1, world_location_2]

      expected_order = [
        world_location_2,
        world_location_1,
      ]

      assert_equal expected_order, sort(unsorted)
    end

    test "ignores `The` prefix when sorting" do
      world_location_1 = create(:world_location, name: "Hungary")
      world_location_2 = create(:world_location, name: "The Gambia")
      unsorted = [world_location_1, world_location_2]

      expected_order = [
        world_location_2,
        world_location_1,
      ]

      assert_equal expected_order, sort(unsorted)
    end

    test "ignores case when sorting" do
      world_location_1 = create(:world_location, name: "UK Mission to ASEAN")
      world_location_2 = create(:world_location, name: "UK and the Commonwealth")
      unsorted = [world_location_1, world_location_2]

      expected_order = [
        world_location_2,
        world_location_1,
      ]

      assert_equal expected_order, sort(unsorted)
    end
  end
end
