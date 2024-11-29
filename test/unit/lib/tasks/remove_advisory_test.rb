require "test_helper"
require "rake"

class RemoveAdvisoryTasksTest < ActiveSupport::TestCase
  teardown do
    Rake::Task["remove_advisory_from_editions:published_editions"].reenable
  end

  test "published_editions processes editions with advisory" do
    edition = create(:published_edition, body: "@example@")

    Rake::Task["remove_advisory_from_editions:published_editions"].invoke

    edition.reload
    assert_match "^example^", edition.body
  end

  test "published_html_attachments processes HTML attachments with advisory" do
    attachment = create(:html_attachment, body: "@example@")
    Rake::Task["remove_advisory_from_editions:published_html_attachments"].invoke

    attachment.reload
    assert_match "^example^", attachment.body
  end
end
