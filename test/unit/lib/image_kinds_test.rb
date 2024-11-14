require "test_helper"

class ImageKindsTest < ActiveSupport::TestCase
  test "builds image kinds when given valid config" do
    result = Whitehall::ImageKinds.build_image_kinds(
      "default" => {
        "display_name" => "default display name",
        "valid_width" => 1,
        "valid_height" => 2,
        "permitted_uses" => [],
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
        "permitted_uses" => [],
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

  test "#permits? checks if use cases are permitted" do
    image_kind = Whitehall::ImageKind.new(
      "default",
      "display_name" => "default display name",
      "valid_width" => 0,
      "valid_height" => 0,
      "permitted_uses" => %w[use_case_1 use_case_2 use_case_3],
      "versions" => [],
    )
    assert_equal(true, image_kind.permits?("use_case_1"))
    assert_equal(true, image_kind.permits?("use_case_2"))
    assert_equal(true, image_kind.permits?("use_case_3"))
    assert_equal(false, image_kind.permits?("use_case_4"))
    assert_equal(false, image_kind.permits?("use_case_5"))
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
