require "test_helper"

class FeatureFlagTest < ActiveSupport::TestCase
  test "enabled? returns false by default" do
    refute FeatureFlag.enabled?("undefined-key")
  end

  test "enabled returns true when set" do
    FeatureFlag.create(key: "new-key", enabled: true)
    assert FeatureFlag.enabled?("new-key")
  end

  test "set sets the value of a flag" do
    FeatureFlag.create(key: "set-key")
    FeatureFlag.set("set-key", true)
    assert FeatureFlag.enabled?("set-key")
    FeatureFlag.set("set-key", false)
    refute FeatureFlag.enabled?("set-key")
  end
end
