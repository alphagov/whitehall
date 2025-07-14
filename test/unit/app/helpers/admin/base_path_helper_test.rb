require "test_helper"

class Admin::BasePathHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  include ApplicationHelper

  describe "#url_to_document_type" do
    test "it maps a URL to a document type" do
      assert_equal Announcement, url_to_document_type("/government/news/slug") # defaults to parent, rather than e.g. NewsArticle
      assert_equal CallForEvidence, url_to_document_type("/government/calls-for-evidence/slug")
      assert_equal CaseStudy, url_to_document_type("/government/case-studies/slug")
      assert_equal Consultation, url_to_document_type("/government/consultations/slug")
      assert_equal DetailedGuide, url_to_document_type("/guidance/slug")
      assert_equal DocumentCollection, url_to_document_type("/government/collections/slug")
      assert_equal FatalityNotice, url_to_document_type("/government/fatalities/slug")
      assert_equal OperationalField, url_to_document_type("/government/fields-of-operation/slug")
      assert_equal Publication, url_to_document_type("/government/publications/slug")
      assert_equal Publication, url_to_document_type("/government/statistics/slug")
      assert_equal Speech, url_to_document_type("/government/speeches/slug")
      assert_equal StatisticalDataSet, url_to_document_type("/government/statistical-data-sets/slug")
      assert_equal StatisticsAnnouncement, url_to_document_type("/government/statistics/announcements/slug")
    end

    test "it raises exception if no document type found for slug" do
      error = assert_raises(RuntimeError) do
        url_to_document_type("/government/foo/slug")
      end

      assert_equal(
        "No document type found for /government/foo/slug",
        error.message,
      )
    end
  end
end
