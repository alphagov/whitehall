require 'test_helper'

class RegisterableEditionTest < ActiveSupport::TestCase
  setup do
    stub_any_publishing_api_call
  end

  test "prepares a detailed guide for registration with Panopticon" do
    edition = create(:published_detailed_guide,
                     title: "Edition title",
                     summary: "Edition summary")
    slug = edition.document.slug

    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "guidance/#{slug}", registerable_edition.slug
    assert_equal "Edition title", registerable_edition.title
    assert_equal "detailed_guide", registerable_edition.kind
    assert_equal "Edition summary", registerable_edition.description
    assert_equal "live", registerable_edition.state
    assert_equal [], registerable_edition.specialist_sectors
    assert_equal ["/guidance/#{slug}"], registerable_edition.paths
    assert_equal [], registerable_edition.prefixes
    assert_equal edition.content_id, registerable_edition.content_id
  end

  test "prepares a translated detailed guide for registration with Panopticon" do
    edition = create(:published_detailed_guide, translated_into: [:cy, :fr],
                     title: "Edition title",
                     summary: "Edition summary")

    slug = edition.document.slug

    registerable_edition = RegisterableEdition.new(edition)

    assert_same_elements ["/guidance/#{slug}", "/guidance/#{slug}.cy", "/guidance/#{slug}.fr"], registerable_edition.paths
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

  test "sets the correct slug for a deleted edition" do
    publication = create(:publication, title: "Edition about a deleted thing")

    Whitehall.edition_services.deleter(publication).perform!

    whitehall_publication_slug = publication.document.slug

    registerable_edition = RegisterableEdition.new(publication)

    assert_equal "deleted-edition-about-a-deleted-thing", whitehall_publication_slug
    assert_equal "government/publications/edition-about-a-deleted-thing", registerable_edition.slug
  end

  test "sets the correct slug and routes for a deleted detailed guide" do
    edition = create(:draft_detailed_guide, title: 'Just A Test')

    Whitehall.edition_services.deleter(edition).perform!
    assert_equal 'deleted-just-a-test', edition.slug

    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "guidance/just-a-test", registerable_edition.slug
    assert_equal ["/guidance/just-a-test"], registerable_edition.paths
    assert_equal [], registerable_edition.prefixes
    assert_equal "archived", registerable_edition.state
  end

  test "sets the state to draft if the edition isn't published" do
    edition = create(:draft_detailed_guide)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "draft", registerable_edition.state
  end

  test "sets the state to archived if the edition has been withdrawn" do
    edition = create(:withdrawn_edition)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "archived", registerable_edition.state
  end

  test "sets the state to archived if the edition has been deleted" do
    edition = create(:deleted_edition)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "archived", registerable_edition.state
  end

  test "sets the state to archived if the edition is unpublished" do
    edition = create(:unpublished_edition)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "archived", registerable_edition.state
    assert_equal "draft", edition.state
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

  test "organisation_ids works with class whose organisation method is not a scope" do
    primary_org = create(:organisation)

    edition = create(:corporate_information_page, organisation: primary_org)
    registerable_edition = RegisterableEdition.new(edition)
    assert_same_elements [primary_org.slug], registerable_edition.organisation_ids
  end

  test "does not tag worldwide organisations yet as they are not registered in Panopticon" do
    worldwide_organisation = create(:worldwide_organisation)

    edition = create(:corporate_information_page, organisation: nil, worldwide_organisation: worldwide_organisation)
    registerable_edition = RegisterableEdition.new(edition)
    assert_equal [], registerable_edition.organisation_ids
  end

  class EditionWithoutOrgs < Edition; end
  test "deals with editions which don't do organisation tagging" do
    registerable_edition = RegisterableEdition.new(EditionWithoutOrgs.new)

    assert_same_elements [], registerable_edition.organisation_ids
  end

  test "sets the need ids for detailed guides" do
    assert_equal ["123456"], RegisterableEdition.new(build(:detailed_guide, need_ids: ["123456"])).need_ids

    assert_equal [], RegisterableEdition.new(build(:statistical_data_set)).need_ids
  end
end
