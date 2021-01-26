require "test_helper"

class LocationsOptionsTest < ActionView::TestCase
  include LocationsOptionsHelper

  test "#locations_options returns locations options with the default selected" do
    location = create(:world_location, :translated)
    option_set = Nokogiri::HTML::DocumentFragment.parse(locations_options)

    option_set.css("option")[0].tap do |option|
      assert_equal "selected", option.attributes["selected"].value
      assert_equal "All locations", option.text
      assert_equal "all", option["value"]
    end

    option_set.css("option")[1].tap do |option|
      assert_equal nil, option.attributes["selected"]
      assert_equal location.name, option.text
      assert_equal location.slug, option["value"]
    end
  end

  test "#locations_options returns locations options with the selected options" do
    location = create(:world_location)
    option_set = Nokogiri::HTML::DocumentFragment.parse(locations_options([location]))

    option_set.css("option")[0].tap do |option|
      assert_equal nil, option.attributes["selected"]
      assert_equal "All locations", option.text
      assert_equal "all", option["value"]
    end

    option_set.css("option")[1].tap do |option|
      assert_equal "selected", option.attributes["selected"].value
      assert_equal location.name, option.text
      assert_equal location.slug, option["value"]
    end
  end
end
