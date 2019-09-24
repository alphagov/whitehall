require "test_helper"

class FractionAssetsTest < ActiveSupport::TestCase
  test "fraction assets directory and contents are fixed" do
    hash = `git rev-parse HEAD^{tree}:app/assets/images/fractions`.chomp
    assert_equal hash, "e6ecee075e5215f9a7820ae82ff56925222b1298"
  end
end
