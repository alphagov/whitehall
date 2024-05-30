require "test_helper"

class NationInapplicabilityTest < ActiveSupport::TestCase
  test "should be invalid with a malformed alternative url" do
    inapplicability = build(:nation_inapplicability, alternative_url: "invalid-url")
    assert_not inapplicability.valid?
  end

  test "should be valid with an alternative url with HTTP protocol" do
    inapplicability = build(:nation_inapplicability, alternative_url: "http://example.com")
    assert inapplicability.valid?
  end

  test "should be valid with an alternative url with HTTPS protocol" do
    inapplicability = build(:nation_inapplicability, alternative_url: "https://example.com")
    assert inapplicability.valid?
  end

  test "should be valid without an alternative url" do
    inapplicability = build(:nation_inapplicability, alternative_url: nil)
    assert inapplicability.valid?
  end

  test "should be valid with 255 character alternative url" do
    alternative_url_255_character = "https://1HHGPav0JgJ6r1rJR34wO2Tksnimp6DjWIrJU02iQgcUK6H7he4aWZ5wrtNGOifEHoLO9afMMfNIZxoOTj6BkQE7NcBwY4fvYpCXwCFaBjnXkRqyl3LfFAIJc5GUXz64LGwQvHQHiOkFdP2fk43HkM2Dx6aHoHxdgRHRB7jVzGNLNwUBQtFdjlLv4CBHRTFMnHBtSsskEXhSGlv0TubV2uouqlUkoLSOwC3AJHa4XN1bcD23112.com"
    inapplicability = build(:nation_inapplicability, alternative_url: alternative_url_255_character)
    assert inapplicability.valid?
  end

  test "should error with more than 255 character alternative url" do
    alternative_url_256_character = "https://1HHGPav0JgJ6r1rJR34wO2Tksnimp6DjWIrJU02iQgcUK6H7he4aWZ5wrtNGOifEHoLO9afMMfNIZxoOTj6BkQE7NcBwY4fvYpCXwCFaBjnXkRqyl3LfFAIJc5GUXz64LGwQvHQHiOkFdP2fk43HkM2Dx6aHoHxdgRHRB7jVzGNLNwUBQtFdjlLv4CBHRTFMnHBtSsskEXhSGlv0TubV2uouqlUkoLSOwC3AJHa4XN1bcD231125.com"
    inapplicability = build(:nation_inapplicability, alternative_url: alternative_url_256_character)
    assert_not inapplicability.valid?
    assert_includes inapplicability.errors.messages[:alternative_url], I18n.t("activerecord.errors.models.nation_inapplicability.attributes.alternative_url.too_long")
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
