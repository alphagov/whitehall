require 'test_helper'

class SupportingPageSearchIndexObserverTest < ActiveSupport::TestCase
  test 'should add supporting page to search index when its edition is published' do
    policy = create(:submitted_policy)
    supporting_page = create(:supporting_page, edition: policy)

    policy.stubs(:supporting_pages).returns([supporting_page])
    ignore_addition_of_policy_to_search_index(policy)

    Searchable::Index.expects(:later).with(supporting_page)

    policy.publish_as(create(:departmental_editor))
  end

  test 'should remove supporting page from search index when its edition is unpublished' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    ignore_removal_of_policy_from_search_index(policy)

    Searchable::Delete.expects(:later).with(supporting_page)

    unpublish_params = {
      'unpublishing_reason_id' => '1',
      'explanation' => 'Was classified',
      'alternative_url' => 'http://website.com/alt',
      'document_type' => 'Policy',
      'slug' => 'some-slug'
    }

    policy.unpublish_as(create(:gds_editor), unpublish_params)
  end

  test 'should remove supporting page from search index when its edition is archived' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    ignore_removal_of_policy_from_search_index(policy)

    Searchable::Delete.expects(:later).with(supporting_page)

    new_edition = policy.create_draft(create(:policy_writer))
    new_edition.reload # because each supporting page touches the new edition as it's copied over
    new_edition.change_note = "change-note"
    new_edition.publish_as(create(:departmental_editor), force: true)
  end

  private

  def ignore_addition_of_policy_to_search_index(policy)
    Searchable::Index.stubs(:later).with(policy)
  end

  def ignore_removal_of_policy_from_search_index(policy)
    Searchable::Delete.stubs(:later).with(policy)
  end
end
