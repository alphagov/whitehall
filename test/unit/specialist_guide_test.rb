require "test_helper"

class SpecialistGuideTest < EditionTestCase
  should_allow_image_attachments
  should_be_attachable
  should_allow_inline_attachments
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test "should be able to relate to topics" do
    article = build(:specialist_guide)
    assert article.can_be_associated_with_topics?
  end

  test "should use specialist guidance as its format name" do
    assert_equal 'specialist guidance', SpecialistGuide.format_name
  end

  test "should use specialist guidance as rummageable search index format" do
    guide = create(:specialist_guide)
    assert_equal "specialist_guidance", guide.search_index["format"]
  end

  test "can be related to another specialist guide" do
    related_guide = create(:specialist_guide)
    guide = create(:specialist_guide, outbound_related_documents: [related_guide.document])
    assert_equal [related_guide], guide.reload.related_specialist_guides
  end

  test "relationships between guides work in both directions" do
    related_guide = create(:specialist_guide)
    guide = create(:specialist_guide, outbound_related_documents: [related_guide.document])
    assert_equal [guide], related_guide.reload.related_specialist_guides
  end

  test "related specialist guides always returns latest edition of related document" do
    published_guide = create(:published_specialist_guide)
    guide = create(:specialist_guide, outbound_related_documents: [published_guide.document])

    latest_edition = published_guide.create_draft(create(:policy_writer))
    assert_equal [latest_edition], guide.reload.related_specialist_guides
  end

  test "published related specialist guides returns latest published edition of related document" do
    published_guide = create(:published_specialist_guide)
    guide = create(:specialist_guide, outbound_related_documents: [published_guide.document])

    latest_edition = published_guide.create_draft(create(:policy_writer))
    assert_equal [published_guide], guide.reload.published_related_specialist_guides
  end

  test "can be associated with some content in the mainstream application" do
    refute build(:specialist_guide).has_related_mainstream_content?
    guide = build(:specialist_guide, related_mainstream_content_url: "http://mainstream/content", related_mainstream_content_title: "Name of content")
    assert guide.has_related_mainstream_content?
  end

  test "can be associated with some additional content in the mainstream application" do
    refute build(:specialist_guide).has_additional_related_mainstream_content?
    guide = build(:specialist_guide, additional_related_mainstream_content_url: "http://mainstream/content", additional_related_mainstream_content_title: "Name of content")
    assert guide.has_additional_related_mainstream_content?
  end

  test "should require a title if related mainstream content url is given" do
    refute build(:specialist_guide, related_mainstream_content_url: "http://mainstream/content").valid?
  end

  test "should require a title if additional related mainstream content url is given" do
    specialist_guide = build(:specialist_guide, additional_related_mainstream_content_url: "http://mainstream/additional-content")
    refute specialist_guide.valid?
  end

  test "should build a draft copy of the existing specialist with the same mainstream categories" do
    primary_mainstream_category = create(:mainstream_category)
    other_mainstream_category = create(:mainstream_category)
    published_guide = create(:published_specialist_guide,
                             primary_mainstream_category: primary_mainstream_category,
                             other_mainstream_categories: [other_mainstream_category])

    draft_guide = published_guide.create_draft(create(:policy_writer))

    assert_equal published_guide.mainstream_categories, draft_guide.mainstream_categories
  end

  test "should be valid if all level-3 headings have a parent level-2 heading" do
    body = "## Parent1\n\n### Child1\n\n### Child2\n\n## Parent2\n\n### Child3"
    specialist_guide = build(:specialist_guide, body: body)
    assert specialist_guide.valid?
  end

  test "should not be valid if level-3 heading has no parent level-2 heading" do
    body = "### Orphan\n\n## Uncle\n\n## Aunt"
    specialist_guide = build(:specialist_guide, body: body)
    refute specialist_guide.valid?
    assert_equal ["must have a level-2 heading (h2 - ##) before level-3 heading (h3 - ###): 'Orphan'"], specialist_guide.errors[:body]
  end

  test "should not be valid without a primary mainstream category" do
    specialist_guide = build(:specialist_guide, primary_mainstream_category: nil)
    refute specialist_guide.valid?
    assert specialist_guide.errors[:primary_mainstream_category]
  end
end
