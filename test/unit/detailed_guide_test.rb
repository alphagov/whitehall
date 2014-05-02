require "test_helper"

class DetailedGuideTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_be_attachable
  should_allow_inline_attachments
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test "relating to detailed guides does not stomp on other related documents" do
    policy        = create(:policy)
    guide         = create(:detailed_guide, related_policy_ids: [policy.id])
    related_guide = create(:detailed_guide)

    guide.update_attributes(related_detailed_guide_ids: [related_guide.id])

    assert_equal [policy], guide.related_policies
    assert_same_elements [policy.document, related_guide.document], guide.related_documents
  end

  test "should be able to relate to topics" do
    article = build(:detailed_guide)
    assert article.can_be_associated_with_topics?
  end

  test "should use detailed guidance as its format name" do
    assert_equal 'detailed guidance', DetailedGuide.format_name
  end

  test "should use detailed guidance as rummageable search index format" do
    guide = create(:detailed_guide)
    assert_equal "detailed_guidance", guide.search_index["format"]
  end

  test 'should be added to the detailed guides rummager index' do
    assert_equal :detailed_guides, build(:detailed_guide).rummager_index
  end

  test "#published_related_detailed_guides returns latest published editions of related documents" do
    published_guide = create(:published_detailed_guide)
    related_guide = create(:published_detailed_guide)
    related_guide.create_draft(create(:policy_writer))
    create(:edition_relation, edition_id: published_guide.id, document: related_guide.document)

    assert_equal [related_guide], published_guide.reload.published_related_detailed_guides
  end

  test "#published_related_detailed_guides does not return non-published editions" do
    published_guide = create(:published_detailed_guide)
    related_draft_guide = create(:detailed_guide)
    published_guide.related_documents << related_draft_guide.document

    assert_equal [], published_guide.reload.published_related_detailed_guides
  end

  test "published_related_detailed_guides returns published editions that are related to the edition's document (i.e. the inverse relationship)" do
    published_guide = create(:published_detailed_guide)
    related_guide = create(:published_detailed_guide)
    published_guide.related_documents << related_guide.document

    assert_equal [published_guide], related_guide.reload.published_related_detailed_guides
  end

  test "published_related_detailed_guides does not return the published edition of documents that were once related to the edition's document" do
    guide = create(:published_detailed_guide)
    related_guide = create(:published_detailed_guide)
    guide.related_documents << related_guide.document

    new_edition = guide.create_draft(create(:policy_writer))
    new_edition.related_document_ids = []
    new_edition.minor_change = true
    force_publish(new_edition)

    assert_equal [], related_guide.reload.published_related_detailed_guides
  end

  test "can be associated with some content in the mainstream application" do
    refute build(:detailed_guide).has_related_mainstream_content?
    guide = build(:detailed_guide, related_mainstream_content_url: "http://mainstream/content", related_mainstream_content_title: "Name of content")
    assert guide.has_related_mainstream_content?
  end

  test "can be associated with some additional content in the mainstream application" do
    refute build(:detailed_guide).has_additional_related_mainstream_content?
    guide = build(:detailed_guide, additional_related_mainstream_content_url: "http://mainstream/content", additional_related_mainstream_content_title: "Name of content")
    assert guide.has_additional_related_mainstream_content?
  end

  test "should require a title if related mainstream content url is given" do
    refute build(:detailed_guide, related_mainstream_content_url: "http://mainstream/content").valid?
  end

  test "should require a title if additional related mainstream content url is given" do
    detailed_guide = build(:detailed_guide, additional_related_mainstream_content_url: "http://mainstream/additional-content")
    refute detailed_guide.valid?
  end

  test "should build a draft copy of the existing detailed with the same mainstream categories" do
    primary_mainstream_category = create(:mainstream_category)
    other_mainstream_category = create(:mainstream_category)
    published_guide = create(:published_detailed_guide,
                             primary_mainstream_category: primary_mainstream_category,
                             other_mainstream_categories: [other_mainstream_category])

    draft_guide = published_guide.create_draft(create(:policy_writer))

    assert_equal published_guide.mainstream_categories, draft_guide.mainstream_categories
  end

  test "should be valid if all level-3 headings have a parent level-2 heading" do
    body = "## Parent1\n\n### Child1\n\n### Child2\n\n## Parent2\n\n### Child3"
    detailed_guide = build(:detailed_guide, body: body)
    assert detailed_guide.valid?
  end

  test "should be invalid if level-3 heading has no parent level-2 heading" do
    body = "### Orphan\n\n## Uncle\n\n## Aunt"
    detailed_guide = build(:detailed_guide, body: body)
    refute detailed_guide.valid?
    assert_equal ["must have a level-2 heading (h2 - ##) before level-3 heading (h3 - ###): 'Orphan'"], detailed_guide.errors[:body]
  end

  test "should include breadcrumb metadata in search index" do
    category = create(:mainstream_category,
      slug: "manufactured-goods-trade-compliance",
      parent_tag: "business/international-trade"
    )
    detailed_guide = create(:published_detailed_guide,
      primary_mainstream_category: category
    )

    index = detailed_guide.search_index
    assert_equal "business", index["section"]
    assert_equal "international-trade", index["subsection"]
    assert_equal "manufactured-goods-trade-compliance", index["subsubsection"]
  end

  test 'search_format_types tags the detailed guide as detailed-guidance' do
    detailed_guide = build(:detailed_guide)
    assert detailed_guide.search_format_types.include?('detailed-guidance')
  end
end
