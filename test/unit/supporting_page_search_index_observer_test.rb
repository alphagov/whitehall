require 'test_helper'

class SupportingPageSearchIndexObserverTest < ActiveSupport::TestCase
  test 'should add supporting page to search index when its document is published' do
    policy = create(:submitted_policy)
    supporting_page = create(:supporting_page, document: policy)

    search_index_data = stub('search index data')
    policy.stubs(:supporting_pages).returns([supporting_page])
    supporting_page.stubs(:search_index).returns(search_index_data)
    Rummageable.stubs(:index) # ignore the update to the document index
    Rummageable.expects(:index).with(search_index_data)

    policy.publish_as(create(:departmental_editor))
  end

  test 'should remove supporting page from search index when its document is archived' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)
    policy_slug = policy.document_identity.slug

    Rummageable.stubs(:delete) # ignore the delete from the document index
    Rummageable.expects(:delete).with("/government/policies/#{policy_slug}/supporting-pages/#{supporting_page.slug}")

    new_edition = policy.create_draft(create(:policy_writer))
    new_edition.reload # because each supporting page touches the new document as it's copied over
    new_edition.change_note = "change-note"
    new_edition.publish_as(create(:departmental_editor), force: true)
  end
end
