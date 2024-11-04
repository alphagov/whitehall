require "test_helper"

class ImageKindsTest < ActiveSupport::TestCase
  test "builds image kinds when given valid config" do
    result = Whitehall::ImageKinds.build_image_kinds(
      "default" => {
        "display_name" => "default display name",
        "valid_width" => 1,
        "valid_height" => 2,
        "versions" => [
          {
            "name" => "some name",
            "width" => 3,
            "height" => 4,
            "from_version" => "some other name",
          },
        ],
      },
    )

    assert_instance_of Hash, result
    assert_pattern do
      result["default"] => {
        display_name: "default display name",
        valid_width: 1,
        valid_height: 2,
        versions: [
          {
            name: "some name",
            width: 3,
            height: 4,
            from_version: "some other name",
          }
        ]
      }
    end
  end

  test "gets version names" do
    result = Whitehall::ImageKinds.build_image_kinds(
      "default" => {
        "display_name" => "default display name",
        "valid_width" => 0,
        "valid_height" => 0,
        "versions" => %w[a b c d e f g].map do
          {
            "name" => _1,
            "width" => 0,
            "height" => 0,
          }
        end,
      },
    )

    assert_equal %w[a b c d e f g], result["default"].version_names
  end

  test "raises errors when given invalid config" do
    # Missing display_name / valid_width / valid_height / versions keys
    assert_raise(KeyError, "key not found") { Whitehall::ImageKinds.build_image_kinds("default" => {}) }

    # Missing versions.name / versions.width / versions.height keys
    assert_raise(KeyError, "key not found") do
      Whitehall::ImageKinds.build_image_kinds("default" => {
        "valid_width" => 0,
        "valid_height" => 0,
        "versions" => [
          {},
        ],
      })
    end
  end
end
