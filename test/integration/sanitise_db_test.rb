require 'test_helper'

class SanitiseDBTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  test 'scrub script runs' do
    `./script/scrub-database --no-copy -d whitehall_test -D whitehall_test`
    assert $?.to_i == 0, "Script exited non-zero"
  end

  test "scrub script sanitises access limited editions" do
    good_edition = create(:edition, title: "Good title", summary: "Good summary", body: "Good body", access_limited: false)
    bad_edition = create(:edition, title: "Bad title", summary: "Bad summary", body: "Bad body", access_limited: true)

    `./script/scrub-database --no-copy -d whitehall_test -D whitehall_test`

    good_edition.reload
    assert_equal "Good title", good_edition.title
    assert_equal "Good summary", good_edition.summary
    assert_equal "Good body", good_edition.body
    assert_equal "good-title", good_edition.slug

    bad_edition.reload
    refute bad_edition.title =~ /Bad title/, "Expected title to be sanitised"
    refute bad_edition.summary =~ /Bad summary/, "Expected summary to be sanitised"
    refute bad_edition.body =~ /Bad body/, "Expected body to be sanitised"
    refute bad_edition.slug =~ /bad-title/, "Expected slug to be sanitised"
  end

  test "scrub script sanitises access limited file attachments" do
    good_attachment = create(:file_attachment, title: "Good title", attachable: create(:edition, access_limited: false))
    bad_attachment = create(:file_attachment, title: "Bad title", attachable: create(:edition, access_limited: true))

    `./script/scrub-database --no-copy -d whitehall_test -D whitehall_test`

    good_attachment.reload
    assert_equal "Good title", good_attachment.title
    assert_equal "greenpaper.pdf", good_attachment.filename

    bad_attachment.reload
    refute bad_attachment.title =~ /Bad title/, "Expected title to be sanitised"
    assert_equal "redacted.pdf", bad_attachment.filename, "Expected filename to be sanitised"
  end

  test "scrub script sanitises access limited html attachments" do
    good_attachment = create(:html_attachment, title: "Good title", body: "Good body", attachable: create(:edition, access_limited: false))
    bad_attachment = create(:html_attachment, title: "Bad title", body: "Bad body", attachable: create(:edition, access_limited: true))

    `./script/scrub-database --no-copy -d whitehall_test -D whitehall_test`

    good_attachment.reload
    assert_equal "Good title", good_attachment.title
    assert_equal "Good body", good_attachment.body
    assert_equal "good-title", good_attachment.slug

    bad_attachment.reload
    refute bad_attachment.title =~ /Bad title/, "Expected title to be sanitised"
    refute bad_attachment.body =~ /Bad body/, "Expected body to be sanitised"
    refute bad_attachment.slug =~ /bad-title/, "Expected slug to be sanitised"
  end

  test "scrub script sanitises supporting pages linked to access limited editions" do
    good_page = create(:supporting_page, title: "Good title", body: "Good body", edition: create(:edition, access_limited: false))
    bad_page = create(:supporting_page, title: "Bad title", body: "Bad body", edition: create(:edition, access_limited: true))

    `./script/scrub-database --no-copy -d whitehall_test -D whitehall_test`

    good_page.reload
    assert_equal "Good title", good_page.title
    assert_equal "Good body", good_page.body
    assert_equal "good-title", good_page.slug

    bad_page.reload
    refute bad_page.title =~ /Bad title/, "Expected title to be sanitised"
    refute bad_page.body =~ /Bad body/, "Expected body to be sanitised"
    refute bad_page.slug =~ /bad-title/, "Expected slug to be sanitised"
  end

  test "scrub script sanitises all fact checks" do
    fact_check = create(:fact_check_request, email_address: "important-person@example.com", comments: "Secret data", instructions: "Secret data", key: "abcdefghijklmnop")

    `./script/scrub-database --no-copy -d whitehall_test -D whitehall_test`

    fact_check.reload
    refute fact_check.email_address =~ /important-person/, "Expected email to be sanitised"
    assert_equal "", fact_check.comments, "Expected comments to be sanitised"
    assert_equal "", fact_check.instructions, "Expected instructions to be sanitised"
    refute fact_check.key =~ /abcdefghijklmnop/, "Expected key to be sanitised"
  end
end
