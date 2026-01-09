require "test_helper"

class Admin::BasePathHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  include ApplicationHelper

  describe "#url_to_document_type" do
    test "it maps a URL to a document type" do
      assert_equal CallForEvidence, url_to_document_type("/government/calls-for-evidence/slug")
      assert_equal CaseStudy, url_to_document_type("/government/case-studies/slug")
      assert_equal Consultation, url_to_document_type("/government/consultations/slug")
      assert_equal DetailedGuide, url_to_document_type("/guidance/slug")
      assert_equal DocumentCollection, url_to_document_type("/government/collections/slug")
      assert_equal FatalityNotice, url_to_document_type("/government/fatalities/slug")
      assert_equal HtmlAttachment, url_to_document_type("/government/calls-for-evidence/slug/attachment-slug")
      assert_equal HtmlAttachment, url_to_document_type("/government/publications/slug/attachment-slug")
      assert_equal OperationalField, url_to_document_type("/government/fields-of-operation/slug")
      assert_equal Publication, url_to_document_type("/government/publications/slug")
      assert_equal Publication, url_to_document_type("/government/statistics/slug")
      assert_equal Speech, url_to_document_type("/government/speeches/slug")
      assert_equal StatisticalDataSet, url_to_document_type("/government/statistical-data-sets/slug")
      assert_equal StatisticsAnnouncement, url_to_document_type("/government/statistics/announcements/slug")
      assert_equal StandardEdition, url_to_document_type("/government/news/slug")
    end

    test "it raises exception if no document type found for base path" do
      error = assert_raises(RuntimeError) do
        url_to_document_type("/government/foo/slug")
      end

      assert_equal(
        "No document type found for /government/foo/slug",
        error.message,
      )
    end
  end

  describe "#url_to_document_slug" do
    test "it extracts the 'slug' that would be stored on the Document" do
      assert_equal "slug", url_to_document_slug("/government/calls-for-evidence/slug")
      assert_equal "slug", url_to_document_slug("/government/case-studies/slug")
      assert_equal "slug", url_to_document_slug("/government/consultations/slug")
      assert_equal "slug", url_to_document_slug("/guidance/slug")
      assert_equal "slug", url_to_document_slug("/government/collections/slug")
      assert_equal "slug", url_to_document_slug("/government/fatalities/slug")
      assert_equal "slug", url_to_document_slug("/government/calls-for-evidence/slug/attachment-slug")
      assert_equal "slug", url_to_document_slug("/government/publications/slug/attachment-slug")
      assert_equal "slug", url_to_document_slug("/government/fields-of-operation/slug")
      assert_equal "slug", url_to_document_slug("/government/publications/slug")
      assert_equal "slug", url_to_document_slug("/government/statistics/slug")
      assert_equal "slug", url_to_document_slug("/government/speeches/slug")
      assert_equal "slug", url_to_document_slug("/government/statistical-data-sets/slug")
      assert_equal "slug", url_to_document_slug("/government/statistics/announcements/slug")
    end
  end
end
