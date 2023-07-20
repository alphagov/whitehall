require "test_helper"

class LocationsOptionsTest < ActionView::TestCase
  include LocationsOptionsHelper

  test "#locations_options returns locations options with the default selected" do
    location = create(:world_location, :translated)

    locations_options[0].tap do |option|
      assert_equal true, option[:selected]
      assert_equal "All locations", option[:text]
      assert_equal "all", option[:value]
    end

    locations_options[1].tap do |option|
      assert_nil option[:selected]
      assert_equal location.name, option[:text]
      assert_equal location.slug, option[:value]
    end
  end

  test "#locations_options returns locations options with the selected options" do
    location = create(:world_location)
    options = locations_options([location])

    options[0].tap do |option|
      assert_nil option[:selected]
      assert_equal "All locations", option[:text]
      assert_equal "all", option[:value]
    end

    options[1].tap do |option|
      assert_equal true, option[:selected]
      assert_equal location.name, option[:text]
      assert_equal location.slug, option[:value]
    end
  end
end
