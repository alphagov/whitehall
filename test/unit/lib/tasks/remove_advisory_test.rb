require "test_helper"
require "rake"

class RemoveAdvisoryTasksTest < ActiveSupport::TestCase
  teardown do
    Rake::Task["remove_advisory:published_editions"].reenable
    Rake::Task["remove_advisory:published_html_attachments"].reenable
  end

  test "published_editions processes editions with advisory" do
    edition = create(:published_edition, body: "@example@")
    create(:gds_team_user, name: "GDS Inside Government Team")

    Rake::Task["remove_advisory:published_editions"].invoke

    new_edition = edition.document.latest_edition
    assert_match "^example^", new_edition.body
  end

  test "published_editions processes editions with advisory followed by 2 empty lines" do
    edition = create(:published_edition, body: "@example\n\n")
    create(:gds_team_user, name: "GDS Inside Government Team")

    Rake::Task["remove_advisory:published_editions"].invoke

    new_edition = edition.document.latest_edition
    assert_match "^example^\n\n", new_edition.body
  end

  test "published_editions processes editions with advisory followed by call to action" do
    edition = create(:published_edition, body: "@example\n$CTA")
    create(:gds_team_user, name: "GDS Inside Government Team")

    Rake::Task["remove_advisory:published_editions"].invoke

    new_edition = edition.document.latest_edition
    assert_match "^example^\n$CTA", new_edition.body
  end

  test "published_html_attachments processes HTML attachments with plain advisory" do
    edition = create(:published_edition)
    attachment = create(:html_attachment, attachable: edition, body: "@example@")
    create(:gds_team_user, name: "GDS Inside Government Team")

    Rake::Task["remove_advisory:published_html_attachments"].invoke

    new_edition = attachment.attachable.document.latest_edition
    new_attachment = new_edition.html_attachments.first
    assert_match "^example^", new_attachment.body
  end

  test "published_html_attachments processes HTML attachments with advisory followed by blank lines" do
    edition = create(:published_edition)
    attachment = create(:html_attachment, attachable: edition, body: "@example\n\n")
    create(:gds_team_user, name: "GDS Inside Government Team")

    Rake::Task["remove_advisory:published_html_attachments"].invoke

    new_edition = attachment.attachable.document.latest_edition
    new_attachment = new_edition.html_attachments.first
    assert_match "^example^", new_attachment.body
  end

  test "published_html_attachments processes HTML attachments with advisory followed by call to action" do
    edition = create(:published_edition)
    attachment = create(:html_attachment, attachable: edition, body: "@example\n$CTA")
    create(:gds_team_user, name: "GDS Inside Government Team")

    Rake::Task["remove_advisory:published_html_attachments"].invoke

    new_edition = attachment.attachable.document.latest_edition
    new_attachment = new_edition.html_attachments.first
    assert_match "^example^", new_attachment.body
  end
end
