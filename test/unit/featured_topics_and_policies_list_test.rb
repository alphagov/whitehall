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

  test 'adding a featured item to the list ensures it is added to the end of the list' do
    list = build(:featured_topics_and_policies_list)
    item_1 = build(:featured_topic_item, featured_topics_and_policies_list: list, ordering: nil)
    list.featured_items << item_1
    refute item_1.ordering.nil?
    item_2 = build(:featured_topic_item, featured_topics_and_policies_list: list, ordering: nil)
    list.featured_items << item_2
    refute item_2.ordering.nil?
    assert item_1.ordering < item_2.ordering
  end

  test 'adding a featured item that already has an ordering to the list doesn\'t change it' do
    list = build(:featured_topics_and_policies_list)
    item_1 = build(:featured_topic_item, featured_topics_and_policies_list: list, ordering: 12)
    list.featured_items << item_1
    assert_equal 12, item_1.ordering
  end

  test 'mostly empty nested attributes for featured items are ignored' do
    list = build(:featured_topics_and_policies_list)
    list.update_attributes(featured_items_attributes: {
      :"0" => {
        item_type: 'Topic',
        ordering: '1'
      }
    })
    assert list.featured_items.empty?
  end
end
