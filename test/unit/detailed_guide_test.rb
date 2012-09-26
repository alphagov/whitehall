require "test_helper"

class DetailedGuideTest < EditionTestCase
  should_allow_image_attachments
  should_be_attachable
  should_allow_inline_attachments
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

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

  test "can be related to another detailed guide" do
    related_guide = create(:detailed_guide)
    guide = create(:detailed_guide, outbound_related_documents: [related_guide.document])
    assert_equal [related_guide], guide.reload.related_detailed_guides
  end

  test "relationships between guides work in both directions" do
    related_guide = create(:detailed_guide)
    guide = create(:detailed_guide, outbound_related_documents: [related_guide.document])
    assert_equal [guide], related_guide.reload.related_detailed_guides
  end

  test "related detailed guides always returns latest edition of related document" do
    published_guide = create(:published_detailed_guide)
    guide = create(:detailed_guide, outbound_related_documents: [published_guide.document])

    latest_edition = published_guide.create_draft(create(:policy_writer))
    assert_equal [latest_edition], guide.reload.related_detailed_guides
  end

  test "published related detailed guides returns latest published edition of related document" do
    published_guide = create(:published_detailed_guide)
    guide = create(:detailed_guide, outbound_related_documents: [published_guide.document])

    latest_edition = published_guide.create_draft(create(:policy_writer))
    assert_equal [published_guide], guide.reload.published_related_detailed_guides
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

  test "should not be valid if level-3 heading has no parent level-2 heading" do
    body = "### Orphan\n\n## Uncle\n\n## Aunt"
    detailed_guide = build(:detailed_guide, body: body)
    refute detailed_guide.valid?
    assert_equal ["must have a level-2 heading (h2 - ##) before level-3 heading (h3 - ###): 'Orphan'"], detailed_guide.errors[:body]
  end

  test "should not be valid without a primary mainstream category" do
    detailed_guide = build(:detailed_guide, primary_mainstream_category: nil)
    refute detailed_guide.valid?
    assert detailed_guide.errors.full_messages.include?("Primary detailed guidance category can't be blank")
  end

  test "should build artefact hash in a suitable format for slimmer to convert into breadcrumb links" do
    detailed_guide = create(:detailed_guide, title: "detailed-guide-title")
    content_api = stub("content-api")
    content_api.stubs(:tag).with("business/tax").returns(parents_hash: true)
    detailed_guide.primary_mainstream_category.stubs(:to_artefact_hash).returns(category_hash: true)

    artefact_hash = detailed_guide.to_artefact_hash(content_api)

    assert_equal "detailed-guide-title", artefact_hash[:title]
    assert_equal "detailedguidance", artefact_hash[:format]
    assert_equal routes_helper.public_document_path(detailed_guide), artefact_hash[:web_url]
    assert_equal [{parent: {parents_hash: true}, category_hash: true}], artefact_hash[:tags]
  end

  test "should not return an artefact hash if primary mainstream category has no parent tag" do
    category = create(:mainstream_category, parent_tag: nil)
    detailed_guide = create(:detailed_guide, primary_mainstream_category: category)
    content_api = stub("content-api", tag: {})

    assert_nil detailed_guide.to_artefact_hash(content_api)
  end

  private

  def routes_helper
    Class.new do
      include Rails.application.routes.url_helpers
      include PublicDocumentRoutesHelper
    end.new
  end
end
