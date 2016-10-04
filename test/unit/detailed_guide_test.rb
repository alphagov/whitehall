require "test_helper"

class DetailedGuideTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_be_attachable
  should_allow_inline_attachments
  should_protect_against_xss_and_content_attacks_on :body, :summary, :change_note

  test "should be able to relate to topics" do
    article = build(:detailed_guide)
    assert article.can_be_associated_with_topics?
  end

  test "should use detailed guidance as its format name" do
    assert_equal "detailed guidance", DetailedGuide.format_name
  end

  test "should use detailed guidance as rummageable search index format" do
    guide = create(:detailed_guide)
    assert_equal "detailed_guidance", guide.search_index["format"]
  end

  test "should be added to the detailed guides rummager index" do
    assert_equal :detailed_guides, build(:detailed_guide).rummager_index
  end

  test "#published_related_detailed_guides returns latest published editions of related documents" do
    published_guide = create(:published_detailed_guide)
    related_guide = create(:published_detailed_guide)
    related_guide.create_draft(create(:writer))
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

    new_edition = guide.create_draft(create(:writer))
    new_edition.related_document_ids = []
    new_edition.minor_change = true
    force_publish(new_edition)

    assert_equal [], related_guide.reload.published_related_detailed_guides
  end

  test "can be associated with some content in the mainstream application" do
    refute build(:detailed_guide).has_related_mainstream_content?
    guide = build(:detailed_guide, related_mainstream_content_url: "http://mainstream/content")
    assert guide.has_related_mainstream_content?
  end

  test "can be associated with some additional content in the mainstream application" do
    refute build(:detailed_guide).has_additional_related_mainstream_content?
    guide = build(:detailed_guide, additional_related_mainstream_content_url: "http://mainstream/content")
    assert guide.has_additional_related_mainstream_content?
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

  test "search_format_types tags the detailed guide as detailed-guidance" do
    detailed_guide = build(:detailed_guide)
    assert detailed_guide.search_format_types.include?("detailed-guidance")
  end

  test "should return base paths for related mainstream content urls" do
    detailed_guide = build(
      :detailed_guide,
      related_mainstream_content_url: "http://gov.uk/content",
      additional_related_mainstream_content_url: "http://gov.uk/additional-content"
    )

    assert_equal detailed_guide.related_mainstream_base_path, "/content"
    assert_equal detailed_guide.additional_related_mainstream_base_path, "/additional-content"
  end

  test "related_detailed_guide_ids works correctly" do
    some_detailed_guide = create(:published_detailed_guide)
    detailed_guide = create(
      :published_detailed_guide,
      related_editions: [some_detailed_guide]
    )

    assert_equal detailed_guide.related_detailed_guide_content_ids, [some_detailed_guide.content_id]
  end

  test "related_mainstream_found works correctly for two correct related mainstream paths" do
    lookup_hash = {
      "/mainstream-content" => "9af50189-de1c-49af-a334-6b1d87b593a6",
      "/another-mainstream-content" => "9dd9e077-ae45-45f6-ad9d-2a484e5ff312"
    }

    publishing_api_has_lookups(lookup_hash)

    detailed_guide = build(
      :detailed_guide,
      related_mainstream_content_url: "http://www.gov.uk/mainstream-content",
      additional_related_mainstream_content_url: "http://www.gov.uk/another-mainstream-content"
    )

    detailed_guide.save

    assert_equal ["9af50189-de1c-49af-a334-6b1d87b593a6", "9dd9e077-ae45-45f6-ad9d-2a484e5ff312"], detailed_guide.related_mainstream_content_ids
  end


  test "related_mainstream_found raises two errors for two incorrect related mainstream paths" do
    Whitehall.publishing_api_v2_client.stubs(:lookup_content_ids).with(base_paths: ["/content-missing-from-publishing-api", "/another-content-missing-from-publishing-api"]).returns({})

    detailed_guide = build(
      :detailed_guide,
      related_mainstream_content_url: "http://www.gov.uk/content-missing-from-publishing-api",
      additional_related_mainstream_content_url: "http://www.gov.uk/another-content-missing-from-publishing-api"
    )

    refute detailed_guide.valid?
    assert_equal ["This mainstream content could not be found"], detailed_guide.errors[:related_mainstream_content_url]
    assert_equal ["This mainstream content could not be found"], detailed_guide.errors[:additional_related_mainstream_content_url]
  end

  test "should persist related mainstream content ids" do
    lookup_hash = {
      "/mainstream-content" => "9af50189-de1c-49af-a334-6b1d87b593a6",
      "/another-mainstream-content" => "9dd9e077-ae45-45f6-ad9d-2a484e5ff312"
    }

    publishing_api_has_lookups(lookup_hash)

    create(
      :detailed_guide,
      related_mainstream_content_url: "http://www.gov.uk/mainstream-content",
      additional_related_mainstream_content_url: "http://www.gov.uk/another-mainstream-content"
    )

    assert_equal 2, RelatedMainstream.count
  end

  test "should not persist related mainstream content ids if edition isn't valid" do
    lookup_hash = {
      "/mainstream-content" => "9af50189-de1c-49af-a334-6b1d87b593a6",
      "/another-mainstream-content" => "9dd9e077-ae45-45f6-ad9d-2a484e5ff312"
    }

    publishing_api_has_lookups(lookup_hash)

    invalid_detailed_guide = build(
      :detailed_guide,
      title: nil,
      related_mainstream_content_url: "http://www.gov.uk/mainstream-content",
      additional_related_mainstream_content_url: "http://www.gov.uk/another-mainstream-content"
    )

    invalid_detailed_guide.save

    assert_equal 0, RelatedMainstream.count
  end

  test "#related_mainstream_content_ids should return the content_ids of associated RelatedMainstream records" do
    lookup_hash = {
      "/mainstream-content" => "9af50189-de1c-49af-a334-6b1d87b593a6",
      "/another-mainstream-content" => "9dd9e077-ae45-45f6-ad9d-2a484e5ff312"
    }

    publishing_api_has_lookups(lookup_hash)

    detailed_guide = create(
      :detailed_guide,
      related_mainstream_content_url: "http://www.gov.uk/mainstream-content",
      additional_related_mainstream_content_url: "http://www.gov.uk/another-mainstream-content"
    )

    assert_equal ["9af50189-de1c-49af-a334-6b1d87b593a6", "9dd9e077-ae45-45f6-ad9d-2a484e5ff312"], detailed_guide.related_mainstream_content_ids
  end

  test "if related_mainstream_content_url gets updated, #persist_content_ids should update existing RelatedMainstream records" do
    lookup_hash = {
      "/mainstream-content" => "9af50189-de1c-49af-a334-6b1d87b593a6",
      "/new-mainstream-content" => "9dd9e077-ae45-45f6-ad9d-2a484e5ff312"
    }

    publishing_api_has_lookups(lookup_hash)

    create(
      :detailed_guide,
      related_mainstream_content_url: "http://www.gov.uk/mainstream-content"
    )

    detailed_guide = DetailedGuide.last
    #we want to mimic the behaviour of creating a detailed guide, then editing it. This clears the @content_ids array as it would do on a new page load.

    detailed_guide.related_mainstream_content_url = "http://www.gov.uk/new-mainstream-content"
    detailed_guide.save

    assert_equal 1, detailed_guide.related_mainstream_content_ids.count
    assert_equal ["9dd9e077-ae45-45f6-ad9d-2a484e5ff312"], detailed_guide.related_mainstream_content_ids
  end

  test "if related_mainstream_content_url gets deleted, #persist_content_ids should delete existing RelatedMainstream records" do
    lookup_hash = {
      "/mainstream-content" => "9af50189-de1c-49af-a334-6b1d87b593a6",
    }

    publishing_api_has_lookups(lookup_hash)

    create(
      :detailed_guide,
      related_mainstream_content_url: "http://www.gov.uk/mainstream-content"
    )

    detailed_guide = DetailedGuide.last
    #we want to mimic the behaviour of creating a detailed guide, then editing it. This clears the @content_ids array as it would do on a new page load.
    detailed_guide.related_mainstream_content_url = nil
    detailed_guide.save

    assert_equal 0, detailed_guide.related_mainstream_content_ids.count
    assert_equal [], detailed_guide.related_mainstream_content_ids
  end

  test "is rendered by government-frontend" do
    assert DetailedGuide.new.rendering_app == Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end
end
