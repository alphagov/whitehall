require 'test_helper'

class RegisterableEditionTest < ActiveSupport::TestCase

  test "prepares an edition for registration with Panopticon" do
    edition = create(:published_edition)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal edition.slug, registerable_edition.slug
    assert_equal edition.title, registerable_edition.title
    assert_equal edition.type.underscore, registerable_edition.kind
    assert_equal edition.summary, registerable_edition.description
    assert_equal "live", registerable_edition.state
    assert_equal [], registerable_edition.industry_sectors
  end

  test "attaches industry sector tags based on mainstream categories for detailed guides" do
    primary_mainstream_category = create(:mainstream_category,
                                         parent_tag: "oil-and-gas",
                                         slug: "industry-sector-oil-and-gas-licensing")
    other_mainstream_category = create(:mainstream_category,
                                        parent_tag: "oil-and-gas",
                                        slug: "industry-sector-oil-and-gas-fields-and-wells")
    detailed_guide = create(:published_detailed_guide,
                             primary_mainstream_category: primary_mainstream_category,
                             other_mainstream_categories: [other_mainstream_category])

    registerable_edition = RegisterableEdition.new(detailed_guide)

    expected_tags = ["oil-and-gas/licensing", "oil-and-gas/fields-and-wells"]
    assert_equal expected_tags, registerable_edition.industry_sectors
  end
end
