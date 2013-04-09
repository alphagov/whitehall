require 'test_helper'

class FeaturedTopicsAndPoliciesListTest < ActiveSupport::TestCase

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

  test 'current_and_linkable_featured_items includes only current featured items that are linkable?' do
    list = create(:featured_topics_and_policies_list)
    current_linkable_item = build(:featured_topic_item, featured_topics_and_policies_list: list, started_at: 2.days.ago)
    ended_item = build(:featured_topic_item, featured_topics_and_policies_list: list, started_at: 3.days.ago, ended_at: 1.day.ago)
    current_unlinkable_item = build(:featured_policy_item, item: create(:draft_policy, :with_document).document, featured_topics_and_policies_list: list, started_at: 4.weeks.ago)
    list.featured_items << current_linkable_item
    list.featured_items << ended_item
    list.featured_items << current_unlinkable_item

    assert list.current_and_linkable_featured_items.include?(current_linkable_item)
    refute list.current_and_linkable_featured_items.include?(ended_item)
    refute list.current_and_linkable_featured_items.include?(current_unlinkable_item)
  end
end
