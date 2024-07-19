require "test_helper"

class Admin::AuditTrailEntryComponentTest < ViewComponent::TestCase
  setup do
    @non_editionable_item = build(:worldwide_organisation)
  end

  test "shows `Organisation created` when the version has an `create` event" do
    version = build(:version, event: "create", item: @non_editionable_item)

    render_inline(Admin::AuditTrailEntryComponent.new(version:))
    assert_selector "h3", text: "Organisation created"
  end

  test "shows `Organisation updated` when the version has an `update` event" do
    version = build(:version, item: @non_editionable_item)

    render_inline(Admin::AuditTrailEntryComponent.new(version:))
    assert_selector "h3", text: "Organisation updated"
  end

  test "shows `No history before this time` when the version has an `initial` event" do
    version = build(:version, event: "initial", item: @non_editionable_item)

    render_inline(Admin::AuditTrailEntryComponent.new(version:))
    assert_selector "h3", text: "No history before this time"
  end

  test "shows `Unknown action` when the version has an event that is not `create` or `update`" do
    version = build(:version, event: "something-else", item: @non_editionable_item)

    render_inline(Admin::AuditTrailEntryComponent.new(version:))
    assert_selector "h3", text: "Unknown action"
  end

  test "shows the author of the event and the time when the version was created" do
    actor = build_stubbed(:user)
    version = build_stubbed(:version, user: actor, item: @non_editionable_item)

    render_inline(Admin::AuditTrailEntryComponent.new(version:))
    assert_selector "p", text: "11 November 2011 11:11am by #{actor.name}"
  end

  test "shows `User (removed)` and the time the version was created when the user record has been removed" do
    version = build_stubbed(:version, whodunnit: "1", item: @non_editionable_item)

    render_inline(Admin::AuditTrailEntryComponent.new(version:))
    assert_selector "p", text: "11 November 2011 11:11am by User (removed)"
  end

  test "shows `User (unknown)` and the time the version was created when there is no associated user record" do
    version = build_stubbed(:version, item: @non_editionable_item)

    render_inline(Admin::AuditTrailEntryComponent.new(version:))
    assert_selector "p", text: "11 November 2011 11:11am by User (unknown)"
  end
end
