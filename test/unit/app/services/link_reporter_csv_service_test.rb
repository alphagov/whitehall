require "test_helper"

class LinkReporterCsvServiceTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers
  include Admin::EditionRoutesHelper

  # Tests are run in parallel. Any shared resources (like files) which the
  # tests use need to be managed carefully. For example the setup method
  # creates a directory, and the teardown method removes it - it's important
  # that this directory is different in each worker, otherwise the first one to
  # finish will remove the directory the others are still using.
  class << self
    attr_writer :worker_number

    def worker_number
      @worker_number || 0
    end
  end

  parallelize_setup do |worker|
    # The parallelize_setup block runs in the context of the class, not the
    # instance. So we have to use a class variable rather than an instance
    # variable to store the worker number.
    self.worker_number = worker
  end

  setup do
    FileUtils.mkdir_p(reports_dir) unless File.directory?(reports_dir)
  end

  teardown do
    if File.directory?(reports_dir)
      FileUtils.rm_rf reports_dir
    end
  end

  test "creates a new csv file with the correct headers" do
    hmrc = create(:organisation, name: "HM Revenue & Customs")
    detailed_guide = create(
      :published_detailed_guide,
      lead_organisations: [hmrc],
      body: "[Good](https://www.test.gov.uk/good-link)\n[broken link](https://www.test.gov.uk/bad-link)\n[Missing page](https://www.test.gov.uk/missing-link)",
    )
    missing_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/missing-link", status: "broken")
    good_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/good-link", status: "ok")
    bad_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/bad-link", status: "broken")
    create(:link_checker_api_report_completed, batch_id: 1, link_reportable: detailed_guide, links: [bad_link, missing_link, good_link])

    LinkReporterCsvService.new(reports_dir:, organisation: hmrc).generate

    csv_test_file_path = reports_dir_pathname.join("hm-revenue-customs_links_report.csv")
    assert File.exist?(csv_test_file_path)

    expected_response = ["page", "admin link", "public timestamp", "format", "broken link count", "broken links"]
    actual_response = CSV.read(csv_test_file_path)
    assert_equal expected_response, actual_response[0]
  end

  test "populates the CSV with details about the broken links per edition" do
    hmrc = create(:organisation, name: "HM Revenue & Customs")
    detailed_guide = create(
      :published_detailed_guide,
      lead_organisations: [hmrc],
      body: "[Good](https://www.test.gov.uk/good-link)\n[broken link](https://www.test.gov.uk/bad-link)\n[Missing page](https://www.test.gov.uk/missing-link)",
    )
    publication = create(
      :published_publication,
      lead_organisations: [hmrc],
      body: "[A broken page](https://www.test.gov.uk/another-bad-link)\n[A good link](https://www.test.gov.uk/another-good-link)",
    )

    bad_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/bad-link", status: "broken")
    another_bad_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/another-bad-link", status: "broken")
    missing_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/missing-link", status: "broken")
    good_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/good-link", status: "ok")
    another_good_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/another-good-link", status: "ok")

    create(:link_checker_api_report_completed, batch_id: 1, link_reportable: detailed_guide, links: [bad_link, missing_link, good_link])
    create(:link_checker_api_report_completed, batch_id: 2, link_reportable: publication, links: [another_good_link, another_bad_link])

    LinkReporterCsvService.new(reports_dir:, organisation: hmrc).generate
    hmrc_csv = CSV.read(reports_dir_pathname.join("hm-revenue-customs_links_report.csv"))
    assert_equal 3, hmrc_csv.size
    assert_equal [detailed_guide.public_url,
                  "https://whitehall-admin.publishing.service.gov.uk#{admin_detailed_guide_path(detailed_guide)}",
                  detailed_guide.public_timestamp.to_s,
                  "DetailedGuide",
                  "2",
                  "https://www.test.gov.uk/bad-link\r\nhttps://www.test.gov.uk/missing-link"],
                 hmrc_csv[1]
    assert_equal [publication.public_url,
                  "https://whitehall-admin.publishing.service.gov.uk#{admin_publication_path(publication)}",
                  publication.public_timestamp.to_s,
                  "Publication",
                  "1",
                  "https://www.test.gov.uk/another-bad-link"],
                 hmrc_csv[2]
  end

  test "populates the csv only with details about broken links on editions associated with the specified organisation" do
    hmrc = create(:organisation, name: "HM Revenue & Customs")
    embassy_paris = create(:worldwide_organisation, name: "British Embassy Paris")
    detailed_guide = create(
      :published_detailed_guide,
      lead_organisations: [hmrc],
      body: "[Good](https://www.test.gov.uk/good-link)\n[broken link](https://www.test.gov.uk/bad-link)\n[Missing page](https://www.test.gov.uk/missing-link)",
    )
    publication = create(
      :published_publication,
      lead_organisations: [hmrc],
      body: "[A broken page](https://www.test.gov.uk/another-bad-link)\n[A good link](https://www.test.gov.uk/another-good-link)",
    )
    news_article = create(
      :news_article_world_news_story,
      :withdrawn,
      worldwide_organisations: [embassy_paris],
      body: "[Good link](https://www.test.gov.uk/good-link)\n[Missing page](https://www.test.gov.uk/missing-link)",
    )

    bad_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/bad-link", status: "broken")
    another_bad_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/another-bad-link", status: "broken")
    missing_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/missing-link", status: "broken")
    good_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/good-link", status: "ok")
    another_good_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/another-good-link", status: "ok")

    create(:link_checker_api_report, batch_id: 1, link_reportable: detailed_guide, links: [bad_link, missing_link, good_link], status: "completed")
    create(:link_checker_api_report, batch_id: 2, link_reportable: publication, links: [another_good_link, another_bad_link], status: "completed")
    create(:link_checker_api_report, batch_id: 3, link_reportable: news_article, links: [good_link, missing_link], status: "completed")

    LinkReporterCsvService.new(reports_dir:, organisation: hmrc).generate
    hmrc_csv = CSV.read(reports_dir_pathname.join("hm-revenue-customs_links_report.csv"))
    assert_not File.file?(reports_dir_pathname.join("british-embassy-paris_links_report.csv"))
    assert_equal 3, hmrc_csv.size
  end

  test "populates the csv only if there is a link check report for the edition" do
    hmrc = create(:organisation, name: "HM Revenue & Customs")
    detailed_guide = create(
      :published_detailed_guide,
      lead_organisations: [hmrc],
      body: "[Good](https://www.test.gov.uk/good-link)\n[broken link](https://www.test.gov.uk/bad-link)\n[Missing page](https://www.test.gov.uk/missing-link)",
    )
    publication = create(
      :published_publication,
      lead_organisations: [hmrc],
      body: "[A broken page](https://www.test.gov.uk/another-bad-link)\n[A good link](https://www.test.gov.uk/another-good-link)",
    )

    bad_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/bad-link", status: "broken")
    missing_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/missing-link", status: "broken")
    good_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/good-link", status: "ok")

    create(:link_checker_api_report_completed, batch_id: 1, link_reportable: detailed_guide, links: [bad_link, missing_link, good_link])

    LinkReporterCsvService.new(reports_dir:, organisation: hmrc).generate
    hmrc_csv = CSV.read(reports_dir_pathname.join("hm-revenue-customs_links_report.csv"))
    assert_equal 2, hmrc_csv.size
    assert_equal ["https://www.test.gov.uk#{detailed_guide.public_path}",
                  "https://whitehall-admin.publishing.service.gov.uk#{admin_detailed_guide_path(detailed_guide)}",
                  detailed_guide.public_timestamp.to_s,
                  "DetailedGuide",
                  "2",
                  "https://www.test.gov.uk/bad-link\r\nhttps://www.test.gov.uk/missing-link"],
                 hmrc_csv[1]
    assert_not_equal [publication.public_url,
                      "https://whitehall-admin.publishing.service.gov.uk#{admin_publication_path(publication)}",
                      publication.public_timestamp.to_s,
                      "Publication",
                      "0",
                      ""],
                     hmrc_csv[2]
  end

  test "creates a new csv file even if no organisation passed to it" do
    speech = create(
      :published_speech,
      person_override: "The Queen",
      body: "[Good link](https://www.test.gov.uk/good-link)\n[Missing page](https://www.test.gov.uk/missing-link)",
      role_appointment: nil,
      create_default_organisation: false,
    )
    missing_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/missing-link", status: "broken")
    good_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/good-link", status: "ok")

    create(:link_checker_api_report_completed, batch_id: 1, link_reportable: speech, links: [missing_link, good_link])

    LinkReporterCsvService.new(reports_dir:).generate

    csv = CSV.read(reports_dir_pathname.join("no-organisation_links_report.csv"))

    csv_test_file_path = reports_dir_pathname.join("no-organisation_links_report.csv")
    assert File.exist?(csv_test_file_path)
    assert_equal 2, csv.size
    assert_equal ["page", "admin link", "public timestamp", "format", "broken link count", "broken links"], csv[0]
    assert_equal [speech.public_url,
                  "https://whitehall-admin.publishing.service.gov.uk#{admin_speech_path(speech)}",
                  speech.public_timestamp.to_s,
                  "Speech",
                  "1",
                  "https://www.test.gov.uk/missing-link"],
                 csv[1]
  end

  test "adds editions to the relevant organisation's csv file if no organisation passed to it" do
    hmrc = create(:organisation, name: "HM Revenue & Customs")
    not_hmrc = create(:organisation, name: "NOT HM Revenue & Customs")

    detailed_guide = create(
      :published_detailed_guide,
      lead_organisations: [hmrc],
      body: "[Good](https://www.test.gov.uk/good-link)\n[broken link](https://www.test.gov.uk/bad-link)\n[Missing page](https://www.test.gov.uk/missing-link)",
    )
    publication = create(
      :published_publication,
      lead_organisations: [not_hmrc],
      body: "[A broken page](https://www.test.gov.uk/another-bad-link)\n[A good link](https://www.test.gov.uk/another-good-link)",
    )

    bad_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/bad-link", status: "broken")
    another_bad_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/another-bad-link", status: "broken")
    missing_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/missing-link", status: "broken")
    good_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/good-link", status: "ok")
    another_good_link = create(:link_checker_api_report_link, uri: "https://www.test.gov.uk/another-good-link", status: "ok")

    create(:link_checker_api_report, batch_id: 1, link_reportable: detailed_guide, links: [bad_link, missing_link, good_link], status: "completed")
    create(:link_checker_api_report, batch_id: 2, link_reportable: publication, links: [another_good_link, another_bad_link], status: "completed")

    LinkReporterCsvService.new(reports_dir:).generate

    hmrc_csv = CSV.read(reports_dir_pathname.join("hm-revenue-customs_links_report.csv"))
    not_hmrc_csv = CSV.read(reports_dir_pathname.join("not-hm-revenue-customs_links_report.csv"))

    assert_equal 2, hmrc_csv.size
    assert_equal 2, not_hmrc_csv.size
  end

private

  def reports_dir_pathname
    Pathname.new(reports_dir)
  end

  def reports_dir
    Rails.root.join("tmp/broken_link_reports/#{self.class.worker_number}")
  end
end
