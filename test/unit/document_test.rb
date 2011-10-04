require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  test 'should return documents that have published editions' do
    archived_document = create(:document, editions: [build(:archived_edition)])
    published_document = create(:document, editions: [build(:published_edition)])
    draft_document = create(:document, editions: [build(:draft_edition)])

    assert_equal [published_document], Document.published
  end

  test 'should return the published edition' do
    document = create(:document)
    archived_edition = create(:archived_edition, document: document)
    published_edition = create(:published_edition, document: document)
    draft_edition = create(:draft_edition, document: document)

    assert_equal published_edition, document.published_edition
  end

  test 'should only return published policies' do
    published_policy = create(:published_policy)
    create(:draft_policy)
    assert_equal [published_policy], Document.published
  end
end