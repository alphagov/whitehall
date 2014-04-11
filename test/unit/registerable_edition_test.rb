require 'test_helper'

class RegisterableEditionTest < ActiveSupport::TestCase

  test "prepares a detailed guide for registration with Panopticon" do
    edition = create(:published_detailed_guide,
                     title: "Edition title",
                     summary: "Edition summary")
    slug = edition.document.slug

    registerable_edition = RegisterableEdition.new(edition)

    assert_equal slug, registerable_edition.slug
    assert_equal "Edition title", registerable_edition.title
    assert_equal "detailed_guide", registerable_edition.kind
    assert_equal "Edition summary", registerable_edition.description
    assert_equal "live", registerable_edition.state
    assert_equal [], registerable_edition.specialist_sectors
    assert_equal ["/#{slug}"], registerable_edition.paths
    assert_equal [], registerable_edition.prefixes
  end

  test "does not set any routes for other formats" do
    edition = create(:published_publication,
                     title: "Edition title",
                     summary: "Edition summary")
    slug = edition.document.slug

    registerable_edition = RegisterableEdition.new(edition)

    assert_equal [], registerable_edition.paths
    assert_equal [], registerable_edition.prefixes
  end

  test "sets the correct slug for a publication" do
    edition = create(:published_publication,
                     title: "Edition title",
                     summary: "Edition summary")
    slug = edition.document.slug

    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "government/publications/#{slug}", registerable_edition.slug
  end

  test "sets the state to draft if the edition isn't published" do
    edition = create(:draft_detailed_guide)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "draft", registerable_edition.state
  end

  test "attaches specialist sector tags based on specialist sectors" do
    expected_primary_tag = "oil-and-gas/taxation"
    expected_secondary_tags = ["oil-and-gas/licensing", "oil-and-gas/fields-and-wells"]

    detailed_guide = create(:published_detailed_guide,
                            primary_specialist_sector_tag: expected_primary_tag,
                            secondary_specialist_sector_tags: expected_secondary_tags)

    registerable_edition = RegisterableEdition.new(detailed_guide)

    assert_equal [expected_primary_tag] + expected_secondary_tags, registerable_edition.specialist_sectors
  end

  test "sets the kind for a generic type" do
    edition = build(:draft_detailed_guide)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "detailed_guide", registerable_edition.kind
  end

  test "sets the kind for a Publication subtype" do
    pub_type = PublicationType.all.first
    edition = build(:publication)
    edition.publication_type = pub_type

    registerable_edition = RegisterableEdition.new(edition)

    assert_equal pub_type.key, registerable_edition.kind
  end

  test "sets the kind for a News Article subtype" do
    art_type = NewsArticleType.all.first
    edition = build(:news_article)
    edition.news_article_type = art_type

    registerable_edition = RegisterableEdition.new(edition)

    assert_equal art_type.key, registerable_edition.kind
  end

  test "sets the kind for a Consultation" do
    edition = build(:consultation)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "consultation", registerable_edition.kind
  end

  test "sets the kind for a Statistical Dataset" do
    edition = build(:statistical_data_set)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "statistical_data_set", registerable_edition.kind
  end

  test "attaches tagged organisations' slugs as `organisation_ids`" do
    primary_org = create(:organisation)
    secondary_org = create(:organisation)

    edition = create(:publication, lead_organisations: [primary_org], supporting_organisations: [secondary_org])
    registerable_edition = RegisterableEdition.new(edition)

    assert_same_elements [primary_org, secondary_org].map(&:slug), registerable_edition.organisation_ids
  end

  class EditionWithoutOrgs < Edition; end
  test "deals with editions which don't do organisation tagging" do
    registerable_edition = RegisterableEdition.new(EditionWithoutOrgs.new)

    assert_same_elements [], registerable_edition.organisation_ids
  end
end
