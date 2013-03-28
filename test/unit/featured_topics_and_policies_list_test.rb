require 'test_helper'

class FeaturedTopicsAndPoliciesListTest < ActiveSupport::TestCase

  test 'is invalid without a summary' do
    list = build(:featured_topics_and_policies_list, summary: nil)
    refute list.valid?
  end

  test "is invalid without an organisation" do
    list = build(:featured_topics_and_policies_list, organisation: nil)
    refute list.valid?
  end

  test 'is invalid if the summary would breach the database field size' do
    list = build(:featured_topics_and_policies_list, summary: 'a' * 65_534) # below max
    assert list.valid?
    list.summary += 'a' # 65_535 - on max
    assert list.valid?
    list.summary += 'a' # 65_536 - above max
    refute list.valid?
  end
end
