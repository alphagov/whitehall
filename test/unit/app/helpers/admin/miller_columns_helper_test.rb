require "test_helper"

class Admin::MillerColumnsHelperTest < ActionView::TestCase
  test "#check_item? returns true if item's checked is true" do
    checked_parent = {
      label: "Parent",
      value: "1",
      checked: true,
      items: [
        {
          label: "Child",
          value: "2",
          checked: false,
          items: [
            label: "Grandchild",
            value: "3",
            items: [],
            checked: false,
          ],
        },
      ],
    }

    assert check_item?(checked_parent)
  end

  test "#check_item? returns true if item's child's checked is true" do
    checked_child = {
      label: "Parent",
      value: "1",
      checked: false,
      items: [
        {
          label: "Child",
          value: "2",
          checked: true,
          items: [
            label: "Grandchild",
            value: "3",
            items: [],
            checked: false,
          ],
        },
      ],
    }

    assert check_item?(checked_child)
  end

  test "#check_item? returns true if item's grandchild's checked is true" do
    checked_grandchild = {
      label: "Parent",
      value: "1",
      checked: false,
      items: [
        {
          label: "Child",
          value: "2",
          checked: false,
          items: [
            label: "Grandchild",
            value: "3",
            items: [],
            checked: true,
          ],

        },
      ],
    }

    assert check_item?(checked_grandchild)
  end

  test "#check_item? returns false if item and children and not checked" do
    unchecked_item = {
      label: "Parent",
      value: "1",
      checked: false,
      items: [
        {
          label: "Child",
          value: "2",
          checked: false,
          items: [
            label: "Grandchild",
            value: "3",
            items: [],
            checked: false,
          ],
        },
      ],
    }

    assert_not check_item?(unchecked_item)
  end
end
