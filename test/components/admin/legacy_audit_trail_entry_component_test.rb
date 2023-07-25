require "test_helper"

class Admin::LegcyAuditTrailEntryComponentTest < ViewComponent::TestCase
  setup do
    @non_editionable_item = create(:worldwide_organisation)
  end

  test "shows `Document created` when the version has an `create` event" do
    version = create(:version, event: "create", item: @non_editionable_item)

    render_inline(Admin::LegacyAuditTrailEntryComponent.new(version:))
    assert_equal page.find("h4").text, "Document created"
  end

  test "shows `Document updated` when the version has an `update` event" do
    version = create(:version, item: @non_editionable_item)

    render_inline(Admin::LegacyAuditTrailEntryComponent.new(version:))
    assert_equal page.find("h4").text, "Document updated"
  end

  test "shows `No history before this time` when the version has an `initial` event" do
    version = create(:version, event: "initial", item: @non_editionable_item)

    render_inline(Admin::LegacyAuditTrailEntryComponent.new(version:))
    assert_equal page.find("h4").text, "No history before this time"
  end

  test "shows `Unknown action` when the version has an event that is not `create` or `update`" do
    version = create(:version, event: "something-else", item: @non_editionable_item)

    render_inline(Admin::LegacyAuditTrailEntryComponent.new(version:))
    assert_equal page.find("h4").text, "Unknown action"
  end

  test "shows the author of the event and the time when the version was created" do
    actor = create(:user)
    version = create(:version, user: actor, item: @non_editionable_item)

    render_inline(Admin::LegacyAuditTrailEntryComponent.new(version:))
    assert_selector "p", text: "11 November 2011 11:11am by #{actor.name}"
  end

  test "shows `User (removed)` and the time the version was created when the user record has been removed" do
    version = create(:version, whodunnit: "1", item: @non_editionable_item)

    render_inline(Admin::LegacyAuditTrailEntryComponent.new(version:))
    assert_selector "p", text: "11 November 2011 11:11am by User (removed)"
  end

  test "shows `User (unknown)` and the time the version was created when there is no associated user record" do
    version = create(:version, item: @non_editionable_item)

    render_inline(Admin::LegacyAuditTrailEntryComponent.new(version:))
    assert_selector "p", text: "11 November 2011 11:11am by User (unknown)"
  end
end
