require "test_helper"

class DocumentSeriesTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :title, :summary, :body


  ### Describing relationships ###

  test "groups should return related DocumentSeriesGroups ordered by document_series_group.ordering" do
    doc_series = create(:document_series, groups: groups = [
      build(:document_series_group),
      build(:document_series_group),
      build(:document_series_group)
    ])
    groups[0].update_attribute(:ordering, 2)
    groups[1].update_attribute(:ordering, 1)
    groups[2].update_attribute(:ordering, 3)

    assert_equal [groups[1], groups[0], groups[2]], doc_series.reload.groups
  end

  test "editions lists all editions associated through the document series' groups" do
    doc_series = create(:document_series)

    pub_1 = create(:publication)
    pub_2 = create(:publication)

    group_1 = create(:document_series_group, document_series: doc_series, documents: [pub_1.document])
    group_2 = create(:document_series_group, document_series: doc_series, documents: [pub_2.document])

    assert doc_series.editions.include? pub_1
    assert doc_series.editions.include? pub_2
  end


  ### Describing validations ###
  should_validate_with_safe_html_validator

  test "it should be invalid without a title" do
    assert_invalid build(:document_series, title: nil)
  end

  test "it should be invalid without a summary" do
    assert_invalid build(:document_series, summary: nil)
  end

  test "it should be invalid without body text" do
    assert_invalid build(:document_series, body: nil)
  end


  ### Describing on create ###
  test "It should create a group called 'Documents' when created if groups are empty" do
    doc_series = create(:document_series, :groups => [])
    assert_equal 1, doc_series.groups.length
    assert_equal "Documents", doc_series.groups[0].heading
  end

  test "It should not create a group if it's already been given one" do
    doc_series = create(:document_series, :groups => [build(:document_series_group, heading: 'not documents')])
    assert_equal 1, doc_series.groups.length
    refute_equal "Documents", doc_series.groups[0].heading
  end


  ### Describing re-drafting behaviour and association cloning ###

  test "It should create new instances of associated DocumentSeriesGroups, with the groups retaining the original groups' member documents" do
    doc_1 = create(:published_news_article).document
    doc_2 = create(:draft_detailed_guide).document
    doc_3 = create(:scheduled_publication).document

    original_doc_series = create(:published_document_series, groups: [
      build(:document_series_group, heading: "Cheese", body: "Differences between cheese types", documents: [doc_1, doc_2]),
      build(:document_series_group, heading: "Famous Llamas", body: "Darth Vadar was infact a llama", documents: [doc_3])
    ])

    redrafted_doc_series = original_doc_series.create_draft(user = create(:gds_editor))

    assert_not_equal original_doc_series.groups[0], redrafted_doc_series.groups[0]

    assert_equal original_doc_series.groups[0].heading, redrafted_doc_series.groups[0].heading
    assert_equal original_doc_series.groups[1].body,    redrafted_doc_series.groups[1].body

    assert_equal [doc_1, doc_2], redrafted_doc_series.groups[0].documents
    assert_equal [doc_3],        redrafted_doc_series.groups[1].documents
  end




  # test 'published_editions returns published editions from series in reverse chronological order' do
  #   series = create(:document_series, :with_group)
  #   draft = create(:draft_publication)
  #   old = create(:published_publication, first_published_at: 2.days.ago)
  #   new = create(:published_publication, first_published_at: 1.day.ago)
  #   group = series.groups.first
  #   group.documents = [draft.document, old.document, new.document]

  #   assert_equal [new, old], series.published_editions
  # end

  # test 'scheduled_editions returns editions that are scheduled for publishing in the series' do
  #   series = create(:document_series, :with_group)
  #   publication = create(:published_publication, first_published_at: 2.days.ago)
  #   scheduled_publication = create(:scheduled_publication)
  #   group = series.groups.first
  #   group.documents = [scheduled_publication.document, publication.document]

  #   assert_equal [scheduled_publication], series.scheduled_editions
  # end


  ### Describing search-related ###

  # test "includes slug in search index data" do
  #   series = create(:document_series, name: "Coffee for the win")
  #   assert_equal 'coffee-for-the-win', series.search_index['slug']
  # end

  # test "indexes the description without markup" do
  #   series = create(:document_series,
  #                   name: "A doc series", description: "This is a *description*")
  #   assert_equal "This is a description", series.search_index["indexable_content"]
  # end

  # test 'indexes the group headings and body copy, without markup' do
  #   group = create(:document_series_group, heading: 'Heading', body: '*Body*')
  #   series = create(:document_series, groups: [group])
  #   assert_match /^Heading$/, series.search_index['indexable_content']
  #   assert_match /^Body$/, series.search_index['indexable_content']
  # end





  # test 'is not deletable if published documents are associated with it' do
  #   series = create(:document_series, :with_group)
  #   group = series.groups.first
  #   group.documents = [create(:published_publication).document]
  #   refute series.destroyable?
  #   series.delete!
  #   assert DocumentSeries.find(series.id)
  # end

  # test 'is deletable if only archived editions are associated' do
  #   series = create(:document_series, documents: [create(:archived_publication).document])
  #   assert series.destroyable?
  #   series.delete!
  #   assert series.deleted?
  # end

  # test "is deletable when there are no associated editions" do
  #   series = create(:document_series)
  #   assert series.destroyable?
  #   series.delete!
  #   assert series.deleted?
  # end
end
