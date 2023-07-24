require "test_helper"

class WorldLocationHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL
  include WorldLocationHelper

  context "#group_and_sort" do
    test "groups and sorts correctly where special characters are used anywhere other than the first character" do
      world_location_1 = create(:world_location, name: "Cow")
      world_location_2 = create(:world_location, name: "Côt")
      unsorted = [world_location_1, world_location_2]

      expected_order = [[
        "C",
        [
          world_location_2,
          world_location_1,
        ],
      ]]

      assert_equal expected_order, group_and_sort(unsorted)
    end

    test "groups and sorts correctly where special characters are used as the first character" do
      world_location_1 = create(:world_location, name: "England")
      world_location_2 = create(:world_location, name: "Éire")
      unsorted = [world_location_1, world_location_2]

      expected_order = [[
        "E",
        [
          world_location_2,
          world_location_1,
        ],
      ]]

      assert_equal expected_order, group_and_sort(unsorted)
    end

    test "ignores `The` prefix when sorting" do
      world_location_1 = create(:world_location, name: "Hungary")
      world_location_2 = create(:world_location, name: "The Gambia")
      unsorted = [world_location_1, world_location_2]

      expected_order = [[
        "G",
        [
          world_location_2,
        ],
      ],
                        [
                          "H",
                          [
                            world_location_1,
                          ],
                        ]]

      assert_equal expected_order, group_and_sort(unsorted)
    end
  end
end
