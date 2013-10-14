require 'test_helper'

class DocumentSeriesGroupTest < ActiveSupport::TestCase
  test 'new groups should set #ordering when assigned to a series' do
    series = create(:document_collection, groups: [
      build(:document_collection_group),
      build(:document_collection_group)
    ])
    assert_equal [1, 2], series.groups.reload.map(&:ordering)
  end

  test "#set_document_ids_in_order! should associate documents and set their\
        membership's ordering to the position of the document id in the passed in array" do
    group = build(:document_collection_group)

    group.documents << doc_1 = create(:document)
    group.documents << doc_2 = create(:document)
                       doc_3 = create(:document)

    group.set_document_ids_in_order! [doc_3.id, doc_1.id]

    assert group.documents.include? doc_1
    assert group.documents.include? doc_3
    refute group.documents.include? doc_2

    assert_equal 0, group.memberships.find_by_document_id(doc_3.id).ordering
    assert_equal 1, group.memberships.find_by_document_id(doc_1.id).ordering
  end

  test '::published_editions should list published editions ordered by membership ordering' do
    group = create(:document_collection_group)
    published_1 = create(:published_publication)
    published_2 = create(:published_publication)
    draft = create(:draft_publication)

    group.set_document_ids_in_order! [draft.document.id, published_2.document.id, published_1.document.id]

    assert_equal [published_2, published_1], group.published_editions
  end

  test '::latest_editions should list latest editions for each document ordered by membership ordering' do
    group = create(:document_collection_group)
    draft = create(:draft_publication)
    published_1 = create(:published_publication)
    published_2 = create(:published_publication)

    group.set_document_ids_in_order! [published_1.document.id, draft.document.id, published_2.document.id]

    assert_equal [published_1, draft, published_2], group.latest_editions
  end

  test '#dup should also clone document memberships' do
    group = create(:document_collection_group, documents: [
      doc_1 = build(:document),
      doc_2 = build(:document),
      doc_3 = build(:document)
    ])

    group.memberships[0].ordering = 2
    group.memberships[1].ordering = 1
    group.memberships[2].ordering = 3

    new_group = group.dup

    assert_not_equal group.memberships[0],          new_group.memberships[0]
    assert_equal     group.memberships[0].document, new_group.memberships[0].document
    assert_equal     1,                             new_group.memberships[1].ordering
    assert_equal     3,                             new_group.memberships[2].ordering
  end
end
