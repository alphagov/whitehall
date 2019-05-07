require 'test_helper'

class SanitiseDBTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    DatabaseCleaner.clean_with :truncation, pre_count: true
  end

  teardown do
    DatabaseCleaner.clean_with :truncation, pre_count: true
  end

  test 'scrub script runs' do
    run_script
    assert Integer($?).zero?, "Script exited non-zero"
  end

  test "scrub script sanitises access limited editions" do
    good_edition = create(:edition, title: "Good title", summary: "Good summary", body: "Good body", access_limited: false)
    bad_edition = create(:edition, title: "Bad title", summary: "Bad summary", body: "Bad body", access_limited: true)

    run_script

    good_edition.reload
    assert_equal "Good title", good_edition.title
    assert_equal "Good summary", good_edition.summary
    assert_equal "Good body", good_edition.body
    assert_equal "good-title", good_edition.slug

    bad_edition.reload
    assert_not bad_edition.title =~ /Bad title/, "Expected title to be sanitised"
    assert_not bad_edition.summary =~ /Bad summary/, "Expected summary to be sanitised"
    assert_not bad_edition.body =~ /Bad body/, "Expected body to be sanitised"
    assert_not bad_edition.slug =~ /bad-title/, "Expected slug to be sanitised"
  end

  test "scrub script sanitises access limited file attachments" do
    good_attachment = create(:file_attachment, title: "Good title", attachable: create(:edition, access_limited: false))
    bad_attachment = create(:file_attachment, title: "Bad title", attachable: create(:edition, access_limited: true))

    run_script

    good_attachment.reload
    assert_equal "Good title", good_attachment.title
    assert_equal "greenpaper.pdf", good_attachment.filename

    bad_attachment.reload
    assert_not bad_attachment.title =~ /Bad title/, "Expected title to be sanitised"
    assert_equal "redacted.pdf", bad_attachment.filename, "Expected filename to be sanitised"
  end

  test "scrub script sanitises access limited html attachments" do
    good_attachment = create(:html_attachment, title: "Good title", body: "Good body", attachable: create(:edition, access_limited: false))
    bad_attachment = create(:html_attachment, title: "Bad title", body: "Bad body", attachable: create(:edition, access_limited: true))

    run_script

    good_attachment.reload
    assert_equal "Good title", good_attachment.title
    assert_equal "Good body", good_attachment.govspeak_content_body
    assert_equal "good-title", good_attachment.slug

    bad_attachment.reload
    assert_not bad_attachment.title =~ /Bad title/, "Expected title to be sanitised"
    assert_not bad_attachment.govspeak_content_body =~ /Bad body/, "Expected body to be sanitised"
    assert_not bad_attachment.slug =~ /bad-title/, "Expected slug to be sanitised"
  end

  test "scrub script sanitises all fact checks" do
    stub_any_publishing_api_call
    fact_check = create(:fact_check_request, email_address: "important-person@example.com", comments: "Secret data", instructions: "Secret data", key: "abcdefghijklmnop")

    run_script

    fact_check.reload
    assert_not fact_check.email_address =~ /important-person/, "Expected email to be sanitised"
    assert_equal "", fact_check.comments, "Expected comments to be sanitised"
    assert_equal "", fact_check.instructions, "Expected instructions to be sanitised"
    assert_not fact_check.key =~ /abcdefghijklmnop/, "Expected key to be sanitised"
  end

private

  def run_script
    database, host, port, username, password = %w(database host port username password).map do |key|
      ActiveRecord::Base.configurations[Rails.env][key]
    end

    # Use the right port, if one is specified in the Rails
    # configuration
    ENV['MYSQL_TCP_PORT'] = port.to_s if port
    host_arg = "-H #{host}" if host

    `./script/scrub-database --no-copy #{host_arg} -D #{database} -U #{username} -P #{password}`
  end
end
