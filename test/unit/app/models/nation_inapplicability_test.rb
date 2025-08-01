require "test_helper"

class NationInapplicabilityTest < ActiveSupport::TestCase
  test "uses UriValidator on :alternative_url" do
    validators = NationInapplicability.validators_on(:alternative_url)
    assert validators.any? { |v| v.is_a?(UriValidator) }, "UriValidator not found on :alternative_url"
  end

  test "has a virtual attribute to indicate exclusion" do
    nation_inapplicability = create(:nation_inapplicability)

    # excluded by default if the record exists
    assert_equal true, nation_inapplicability.excluded?

    # not excluded if excluded attribute is set to '0'
    nation_inapplicability.excluded = "0"
    assert_equal false, nation_inapplicability.excluded?

    # still excluded if attribute is '1'
    nation_inapplicability.excluded = "1"
    assert_equal true, nation_inapplicability.excluded?

    # non-persisted records are not excuded unless explicitly set
    assert_equal false, NationInapplicability.new.excluded?
    assert_equal false, NationInapplicability.new(excluded: "0").excluded?
    assert_equal true, NationInapplicability.new(excluded: "1").excluded?
  end
end
