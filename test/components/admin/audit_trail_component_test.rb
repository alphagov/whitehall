require "test_helper"

class Admin::AuditTrailComponentTest < ViewComponent::TestCase
  setup do
    @non_editionable_item = create(:worldwide_organisation)
  end

  test "renders audit trail entries" do
    create(:version, event: "create", item: @non_editionable_item)
    create(:version, event: "update", item: @non_editionable_item)
    versions = @non_editionable_item.versions_desc.page(1)

    render_inline(Admin::AuditTrailComponent.new(versions:))

    assert_selector "h3", text: "Organisation created"
    assert_selector "h3", text: "Organisation updated"
  end
end
