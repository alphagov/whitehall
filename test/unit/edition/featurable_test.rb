require "test_helper"

class Edition::FeaturableTest < ActiveSupport::TestCase
  test "should not be featured by default" do
    featurable = create(:published_publication)
    refute featurable.featured?
  end

  test "should be featured when featured" do
    featurable = create(:published_publication)
    featurable.feature
    assert featurable.featured?
  end

  test "should not be featured when unfeatured" do
    featurable = create(:featured_publication)
    featurable.unfeature
    refute featurable.featured?
  end
end
