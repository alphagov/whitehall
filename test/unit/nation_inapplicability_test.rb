require 'test_helper'

class NationInapplicabilityTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    inapplicability = build(:nation_inapplicability)
    assert inapplicability.valid?
  end

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
end