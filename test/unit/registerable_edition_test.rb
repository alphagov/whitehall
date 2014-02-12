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
    assert_equal [], registerable_edition.industry_sectors
  end

  test "sets the state to draft if the edition isn't published" do
    edition = create(:draft_detailed_guide)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal "draft", registerable_edition.state
  end

  test "attaches industry sector tags based on specialist sectors" do
    expected_tags = ["oil-and-gas/licensing", "oil-and-gas/fields-and-wells"]

    detailed_guide = create(:published_detailed_guide,
                            specialist_sector_tags: expected_tags)

    registerable_edition = RegisterableEdition.new(detailed_guide)

    assert_equal expected_tags, registerable_edition.industry_sectors
  end
end
