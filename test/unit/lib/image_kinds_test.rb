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

  test "#version_names returns version names" do
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

  test "#version_names returns prefixed names for kinds with 'version_prefix' true" do
    result = Whitehall::ImageKinds.build_image_kinds(
      "topical_event_logo" => {
        "display_name" => "Logo",
        "valid_width" => 1506,
        "valid_height" => 1004,
        "version_prefix" => true,
        "versions" => [
          { "name" => "tablet_2x", "width" => 1506, "height" => 1004 },
          { "name" => "desktop", "width" => 482, "height" => 321, "from_version" => "tablet_2x" },
        ],
      },
    )

    assert_equal %w[topical_event_logo_tablet_2x topical_event_logo_desktop], result["topical_event_logo"].version_names
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

  test "#display_name_without_dimensions returns display name without the dimensions" do
    result = Whitehall::ImageKinds.build_image_kinds(
      "test_kind" => {
        "display_name" => "Test Kind (300x200)",
        "valid_width" => 300,
        "valid_height" => 200,
        "versions" => [],
      },
    )

    assert_equal "Test Kind", result["test_kind"].display_name_without_dimensions
  end

  test "prefixes 'name' and 'from_version' when version_prefix config true" do
    result = Whitehall::ImageKinds.build_image_kinds(
      "topical_event_logo" => {
        "display_name" => "Logo",
        "valid_width" => 1506,
        "valid_height" => 1004,
        "version_prefix" => true,
        "versions" => [
          { "name" => "tablet_2x", "width" => 1506, "height" => 1004 },
          { "name" => "tablet", "width" => 738, "height" => 492, "from_version" => "tablet_2x" },
        ],
      },
    )

    versions = result["topical_event_logo"].versions
    assert_equal "topical_event_logo_tablet_2x", versions[0].prefixed_name
    assert_equal "topical_event_logo_tablet", versions[1].prefixed_name
    assert_equal "topical_event_logo_tablet_2x", versions[1].prefixed_from_version
  end

  test "does not prefix 'name' and 'from_version' when 'version_prefix' config false" do
    result = Whitehall::ImageKinds.build_image_kinds(
      "default" => {
        "display_name" => "Default",
        "valid_width" => 960,
        "valid_height" => 640,
        "versions" => [
          { "name" => "s960", "width" => 960, "height" => 640 },
        ],
      },
    )

    version = result["default"].versions.first
    assert_equal "s960", version.prefixed_name
    assert_nil version.prefixed_from_version
  end
end
