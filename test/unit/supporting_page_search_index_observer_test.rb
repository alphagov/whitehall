require 'test_helper'

class SupportingPageSearchIndexObserverTest < ActiveSupport::TestCase
  test 'should remove supporting page from search index when its edition is unpublished' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    ignore_removal_of_policy_from_search_index(policy)

    Searchable::Delete.expects(:later).with(supporting_page)
    policy.unpublishing = build(:unpublishing)
    policy.perform_unpublish
  end

  test 'should remove supporting page from search index when its edition is archived' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    ignore_removal_of_policy_from_search_index(policy)

    Searchable::Delete.expects(:later).with(supporting_page)

    new_edition = policy.create_draft(create(:policy_writer))
    new_edition.reload # because each supporting page touches the new edition as it's copied over
    new_edition.change_note = "change-note"
    force_publish(new_edition)
  end

  private

  def ignore_addition_of_policy_to_search_index(policy)
    Searchable::Index.stubs(:later).with(policy)
  end

  def ignore_removal_of_policy_from_search_index(policy)
    Searchable::Delete.stubs(:later).with(policy)
  end
end
