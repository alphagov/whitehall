require 'test_helper'

class NationInapplicabilityTest < ActiveSupport::TestCase
  test 'should be invalid with a malformed alternative url' do
    inapplicability = build(:nation_inapplicability, alternative_url: "invalid-url")
    refute inapplicability.valid?
  end

  test 'should be valid with an alternative url with HTTP protocol' do
    inapplicability = build(:nation_inapplicability, alternative_url: "http://example.com")
    assert inapplicability.valid?
  end

  test 'should be valid with an alternative url with HTTPS protocol' do
    inapplicability = build(:nation_inapplicability, alternative_url: "https://example.com")
    assert inapplicability.valid?
  end

  test 'should be valid without an alternative url' do
    inapplicability = build(:nation_inapplicability, alternative_url: nil)
    assert inapplicability.valid?
  end

  test "has a virtual attribute to indicate exclusion" do
    nation_inapplicability = create(:nation_inapplicability)

    # excluded by default if the record exists
    assert_equal true, nation_inapplicability.excluded?

    # not excluded if excluded attribute is set to '0'
    nation_inapplicability.excluded = '0'
    assert_equal false, nation_inapplicability.excluded?

    # still excluded if attribute is '1'
    nation_inapplicability.excluded = '1'
    assert_equal true, nation_inapplicability.excluded?

    # non-persisted records are not excuded unless explicitly set
    assert_equal false, NationInapplicability.new.excluded?
    assert_equal false, NationInapplicability.new(excluded: '0').excluded?
    assert_equal true, NationInapplicability.new(excluded: '1').excluded?
  end
end
