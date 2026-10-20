require "test_helper"

class Presenters::PublishingApi::NationApplicabilityHelperTest < ActiveSupport::TestCase
  include Presenters::PublishingApi::NationApplicabilityHelper

  test "cast_nation_applicability returns an empty array when value is not a hash" do
    assert_equal [], cast_nation_applicability(nil)
    assert_equal [], cast_nation_applicability("not a hash")
  end

  test "cast_nation_applicability returns an empty array when nothing is selected" do
    assert_equal [], cast_nation_applicability({ "selected" => [] })
  end

  test "cast_nation_applicability pairs each selected nation with its alternative URL" do
    value = {
      "selected" => %w[england wales],
      "wales" => { "alternative_url" => "https://example.cy" },
    }

    assert_equal(
      [
        { "nation" => "england" },
        { "nation" => "wales", "alternative_url" => "https://example.cy" },
      ],
      cast_nation_applicability(value),
    )
  end
end
