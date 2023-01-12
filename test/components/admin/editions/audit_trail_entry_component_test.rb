# frozen_string_literal: true

require "test_helper"

class Admin::Editions::AuditTrailEntryComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "it constructs output based on the entry when an actor is present" do
    actor = create(:user)
    edition = create(:edition)
    version = edition.versions.create!(event: "create", created_at: Time.zone.local(2020, 1, 1, 11, 11), whodunnit: actor.id)
    audit = Document::PaginatedHistory::AuditTrailEntry.new(version, is_first_edition: true)

    render_inline(Admin::Editions::AuditTrailEntryComponent.new(entry: audit, edition:))

    assert_equal page.find("h4").text, "Document created"
    assert_equal page.all("p")[0].text.strip, "1 January 2020 11:11am by #{actor.name}"
    assert_equal page.find("p a").text, actor.name
    assert_equal page.find("p a")[:href], "/government/admin/authors/#{actor.id}"
  end

  test "it constructs output based on the entry when an actor is absent" do
    edition = build_stubbed(:edition)
    version = edition.versions.new(event: "create", created_at: Time.zone.local(2020, 1, 1, 11, 11), whodunnit: nil)
    audit = Document::PaginatedHistory::AuditTrailEntry.new(version, is_first_edition: true)

    render_inline(Admin::Editions::AuditTrailEntryComponent.new(entry: audit, edition:))

    assert_equal page.find("h4").text, "Document created"
    assert_equal page.all("p")[0].text.strip, "1 January 2020 11:11am by User (removed)"
  end

  test "it links to the diff page is the action is published and the edition passed in is different to the versions" do
    actor = create(:user)
    edition = create(:edition, :published)
    edition.versions.create!(event: "create", created_at: Time.zone.local(2020, 1, 1, 11, 11), whodunnit: actor.id)
    version = edition.versions.create!(event: "published", created_at: Time.zone.local(2020, 1, 1, 11, 11), whodunnit: actor.id, state: "published")
    audit = Document::PaginatedHistory::AuditTrailEntry.new(version, is_first_edition: true)
    newer_edition = create(:edition, :draft)

    render_inline(Admin::Editions::AuditTrailEntryComponent.new(entry: audit, edition: newer_edition))

    assert_equal page.find("h4").text, "Document published"
    assert_equal page.all("p")[0].text.strip, "[Compare with previous version]"
    assert_equal page.all("p")[1].text.strip, "1 January 2020 11:11am by #{actor.name}"
    assert_equal page.all("p a")[0].text, "[Compare with previous version]"
    assert_equal page.all("p a")[0][:href], diff_admin_edition_path(newer_edition, audit_trail_entry_id: version.item_id)
    assert_equal page.all("p a")[1].text, actor.name
    assert_equal page.all("p a")[1][:href], admin_author_path(actor)
  end
end
