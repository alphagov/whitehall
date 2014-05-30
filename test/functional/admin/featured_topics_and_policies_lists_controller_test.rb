require 'test_helper'

class Admin::FeaturedTopicsAndPoliciesListsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  test "GET show fetches the featured topics and policies list for the supplied org" do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    get :show, organisation_id: org

    assert_equal featured_topics_and_policies_list, assigns(:featured_topics_and_policies_list)
  end

  test "GET show fetches an unsaved featured topics and policies list for the supplied org if it doesn't already have one" do
    org = create(:organisation)

    get :show, organisation_id: org

    list = assigns(:featured_topics_and_policies_list)
    assert list
    assert_equal org, list.organisation
    refute list.persisted?
  end

  test 'GET show will fetch only the current featured_items for the list' do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)
    current_item = create(:featured_topic_item, featured_topics_and_policies_list: featured_topics_and_policies_list)
    ended_item = create(:featured_topic_item, featured_topics_and_policies_list: featured_topics_and_policies_list, started_at: 2.days.ago, ended_at: 1.day.ago)

    get :show, organisation_id: org
    items = assigns(:featured_items)
    assert items.include?(current_item)
    refute items.include?(ended_item)
  end

  test 'GET show will add an unsaved featured_item for a topic to the end of the fetched featured items' do
    org = create(:organisation)

    get :show, organisation_id: org
    list = assigns(:featured_topics_and_policies_list)
    items = assigns(:featured_items)
    assert_equal 1, items.size
    refute items.first.persisted?
    assert_equal 'Topic', items.first.item_type
  end

  test "PUT update will save the supplied changes to the featured topics and policies list for the supplied org" do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    put :update, organisation_id: org, featured_topics_and_policies_list: { summary: 'Wooo' }

    assert_equal 'Wooo', featured_topics_and_policies_list.reload.summary
  end

  test "PUT update will create a featured topics and policies list for the supplied org if it doesn't already have one" do
    org = create(:organisation)

    put :update, organisation_id: org, featured_topics_and_policies_list: { summary: 'Wooo' }

    list = assigns(:featured_topics_and_policies_list)
    assert list
    assert_equal org, list.organisation
    assert list.persisted?
    assert_equal 'Wooo', list.summary
  end

  test "PUT update with an unfeature param set to 1 will set the ended_at date of the featured item (making it no longer current)" do
    org = create(:organisation)
    t = create(:topic)
    p = create(:policy, :with_document)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)
    item = build(:featured_topic_item, featured_topics_and_policies_list: featured_topics_and_policies_list)
    featured_topics_and_policies_list.featured_items << item

    put :update, organisation_id: org, featured_topics_and_policies_list: {
      featured_items_attributes: {
        :"0" => {
          id: item.id,
          unfeature: '1'
        }
      }
    }

    refute featured_topics_and_policies_list.featured_items.current.include?(item)
    item.reload
    assert_equal Time.current, item.ended_at
  end

  test "PUT update with an unfeature param set to 0 will ignore the param and not set the ended_at date of the featured item" do
    org = create(:organisation)
    t = create(:topic)
    p = create(:policy, :with_document)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)
    item = build(:featured_topic_item, featured_topics_and_policies_list: featured_topics_and_policies_list)
    featured_topics_and_policies_list.featured_items << item

    put :update, organisation_id: org, featured_topics_and_policies_list: {
      featured_items_attributes: {
        :"0" => {
          id: item.id,
          unfeature: '0'
        }
      }
    }

    assert featured_topics_and_policies_list.featured_items.current.include?(item)
    item.reload
    refute item.ended_at.present?
  end

  test "PUT update will save featured items, using item_type to choose between topic_id and document_id params" do
    org = create(:organisation)
    t = create(:topic)
    p = create(:policy, :with_document)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    put :update, organisation_id: org, featured_topics_and_policies_list: {
      featured_items_attributes: {
        :"0" => {
          item_type: 'Topic',
          topic_id: t.id.to_s,
          document_id: p.document.id.to_s,
          ordering: '1'
        },
        :"1" => {
          item_type: 'Document',
          topic_id: t.id.to_s,
          document_id: p.document.id.to_s,
          ordering: '2'
        }
      }
    }

    list = assigns(:featured_topics_and_policies_list)
    items = list.featured_items
    featured_topic = items.detect { |i| i.ordering == 1 }
    assert_equal t, featured_topic.item
    assert featured_topic.persisted?

    featured_policy = items.detect { |i| i.ordering == 2 }
    assert_equal p.document, featured_policy.item
    assert featured_policy.persisted?
  end

  test "PUT update that fails will render the show template" do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    put :update, organisation_id: org, featured_topics_and_policies_list: { summary: ('a' * 65_536) }

    assert_template :show
  end

  test 'PUT update that fails will fetch only the existing current featured items (including those about to become un-current by user action), or unpersisted ones, in order' do
    org = create(:organisation)
    t = create(:topic)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)
    current_item = build(:featured_topic_item, featured_topics_and_policies_list: featured_topics_and_policies_list)
    ended_item = build(:featured_topic_item, featured_topics_and_policies_list: featured_topics_and_policies_list, started_at: 2.days.ago, ended_at: 1.day.ago)
    to_be_ended_item = build(:featured_topic_item, featured_topics_and_policies_list: featured_topics_and_policies_list, started_at: 2.days.ago)
    featured_topics_and_policies_list.featured_items << current_item
    featured_topics_and_policies_list.featured_items << ended_item
    featured_topics_and_policies_list.featured_items << to_be_ended_item

    put :update, organisation_id: org, featured_topics_and_policies_list: {
      summary: ('a' * 65_536),
      featured_items_attributes: {
        :"0" => {
          id: current_item.id,
          item_type: current_item.item_type,
          topic_id: current_item.topic_id,
          ordering: '2'
        },
        :"1" => {
          item_type: 'Topic',
          topic_id: t.id.to_s,
          ordering: '1'
        },
        :"2" => {
          id: to_be_ended_item.id,
          unfeature: '1',
          ordering: '3'
        }
      }
    }

    items = assigns(:featured_items)

    refute items.include?(ended_item)
    assert_equal 3, items.size
    refute items[0].persisted?
    assert_equal current_item, items[1]
    assert_equal to_be_ended_item, items[2]
    assert items[2].ended_at.present?
  end
end
