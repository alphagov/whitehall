require "test_helper"

class NationApplicabilityTest < ActiveSupport::TestCase
  test "cast returns an empty array when value is not a hash" do
    assert_equal [], NationApplicability.cast(nil)
    assert_equal [], NationApplicability.cast("not a hash")
  end

  test "cast returns an empty array when nothing is selected" do
    assert_equal [], NationApplicability.cast({ "selected" => [] })
  end

  test "cast pairs each selected nation with its alternative URL" do
    value = {
      "selected" => %w[england wales],
      "wales" => { "alternative_url" => "https://example.cy" },
    }

    assert_equal(
      [
        { "nation" => "england" },
        { "nation" => "wales", "alternative_url" => "https://example.cy" },
      ],
      NationApplicability.cast(value),
    )
  end
end
