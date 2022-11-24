# frozen_string_literal: true

require "test_helper"

class Admin::Editions::AuditTrailEntryComponentTest < ViewComponent::TestCase
  test "it constructs output based on the entry when an actor is present" do
    actor = create(:user)
    edition = create(:edition)
    version = edition.versions.create!(event: "create", created_at: Time.zone.local(2020, 1, 1, 11, 11), whodunnit: actor.id)
    audit = Document::PaginatedHistory::AuditTrailEntry.new(version, is_first_edition: true)

    render_inline(Admin::Editions::AuditTrailEntryComponent.new(entry: audit))

    assert_equal page.text, "\n  Created by  #{actor.name}\n  \n   1 January 2020 11:11am\n\n"
    assert_equal page.find("li a").text, actor.name
    assert_equal page.find("li a")[:href], "/government/admin/authors/#{actor.id}"
  end

  test "it constructs output based on the entry when an actor is absent" do
    edition = build_stubbed(:edition)
    version = edition.versions.new(event: "create", created_at: Time.zone.local(2020, 1, 1, 11, 11), whodunnit: nil)
    audit = Document::PaginatedHistory::AuditTrailEntry.new(version, is_first_edition: true)

    render_inline(Admin::Editions::AuditTrailEntryComponent.new(entry: audit))

    assert_equal page.text, "\n  Created by  User (removed)\n  \n   1 January 2020 11:11am\n\n"
  end
end
