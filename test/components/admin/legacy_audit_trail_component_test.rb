require "test_helper"

class Admin::LegacyAuditTrailComponentTest < ViewComponent::TestCase
  setup do
    @non_editionable_item = create(:worldwide_organisation)
  end

  test "renders audit trail entries" do
    create(:version, event: "create", item: @non_editionable_item)
    create(:version, event: "update", item: @non_editionable_item)
    versions = @non_editionable_item.versions_desc.page(1)

    render_inline(Admin::LegacyAuditTrailComponent.new(versions:))

    assert_selector "h4", text: "Document created"
    assert_selector "h4", text: "Document updated"
  end
end
