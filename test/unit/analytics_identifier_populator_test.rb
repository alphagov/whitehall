require 'test_helper'

class AnalyticsIdentifierPopulatorTest < ActiveSupport::TestCase
  class TestEdition
    # Behave like ActiveRecord class
    def self.after_create(callback); end

    include AnalyticsIdentifierPopulator
    self.analytics_prefix = "TE"
  end

  test "raises exception if analytics_prefix is not defined" do
    TestEdition.analytics_prefix = nil

    assert_raise RuntimeError,
      "AnalyticsIdentifierPopulatorTest::TestEdition must assign a value to attribute analytics_prefix" do
      TestEdition.new.ensure_analytics_identifier
    end
  end
end
