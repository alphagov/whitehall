require "test_helper"

class Admin::LeadImageHelperTest < ActionView::TestCase
  include Admin::LeadImageHelper

  test "renders default lead image if all asset variants have been uploaded" do
    lead_image = stub(
      all_asset_variants_uploaded?: true,
      url: "/image.jpg",
    )

    edition = stub(
      default_lead_image: lead_image,
      placeholder_image_url: "/placeholder.jpg",
    )

    result = lead_image_fallback_thumbnail(edition)

    assert_includes result, 'src="/image.jpg"'
    assert_includes result, 'class="app-view-edition-resource__preview"'
  end

  test "renders placeholder image if asset variants are not uploaded" do
    lead_image = stub(
      all_asset_variants_uploaded?: false,
    )

    edition = stub(
      default_lead_image: lead_image,
      placeholder_image_url: "/placeholder.jpg",
    )

    result = lead_image_fallback_thumbnail(edition)

    assert_includes result, 'src="/placeholder.jpg"'
    assert_includes result, 'class="app-view-edition-resource__preview"'
  end

  test "renders placeholder image if no default lead image exists" do
    edition = stub(
      default_lead_image: nil,
      placeholder_image_url: "/placeholder.jpg",
    )

    result = lead_image_fallback_thumbnail(edition)

    assert_includes result, 'src="/placeholder.jpg"'
  end
end
