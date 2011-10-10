require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  test 'should return documents that have published editions' do
    archived_policy = create(:archived_policy)
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy)

    assert_equal [published_policy.document], Document.published
  end

  test 'should return the published edition' do
    document = create(:document)
    archived_policy = create(:archived_policy, document: document)
    published_policy = create(:published_policy, document: document)
    draft_policy = create(:draft_policy, document: document)

    assert_equal published_policy, document.published_edition
  end
end