require 'test_helper'

class SupportingPageSearchIndexObserverTest < ActiveSupport::TestCase
  test 'should add supporting page to search index when its edition is published' do
    policy = create(:submitted_policy)
    supporting_page = create(:supporting_page, edition: policy)

    search_index_data = stub('search index data')
    policy.stubs(:supporting_pages).returns([supporting_page])
    supporting_page.stubs(:search_index).returns(search_index_data)
    ignore_addition_of_policy_to_search_index(policy)

    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_path)

    policy.publish_as(create(:departmental_editor))
  end

  test 'should remove supporting page from search index when its edition is unpublished' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    supporting_page_path = "/government/policies/#{policy.document.to_param}/supporting-pages/#{supporting_page.to_param}"
    ignore_removal_of_policy_from_search_index(policy)

    Rummageable.expects(:delete).with(supporting_page_path, Whitehall.government_search_index_path)

    policy.unpublish_as(create(:gds_editor))
  end

  test 'should remove supporting page from search index when its edition is archived' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    supporting_page_path = "/government/policies/#{policy.document.to_param}/supporting-pages/#{supporting_page.to_param}"
    ignore_removal_of_policy_from_search_index(policy)

    Rummageable.expects(:delete).with(supporting_page_path, Whitehall.government_search_index_path)

    new_edition = policy.create_draft(create(:policy_writer))
    new_edition.reload # because each supporting page touches the new edition as it's copied over
    new_edition.change_note = "change-note"
    new_edition.publish_as(create(:departmental_editor), force: true)
  end

  private

  def ignore_addition_of_policy_to_search_index(policy)
    Rummageable.stubs(:index).with(anything, anything)
  end

  def ignore_removal_of_policy_from_search_index(policy)
    Rummageable.stubs(:delete).with("/government/policies/#{policy.document.to_param}", anything)
  end
end
