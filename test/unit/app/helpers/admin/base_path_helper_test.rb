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

  describe "#document_type_and_slug_to_base_path" do
    test "it maps a document type and slug to a base_path" do
      assert_equal "/government/news/slug", document_type_and_slug_to_base_path(Announcement, "slug")
      assert_equal "/government/calls-for-evidence/slug", document_type_and_slug_to_base_path(CallForEvidence, "slug")
      assert_equal "/government/case-studies/slug", document_type_and_slug_to_base_path(CaseStudy, "slug")
      assert_equal "/government/consultations/slug", document_type_and_slug_to_base_path(Consultation, "slug")
      assert_equal "/guidance/slug", document_type_and_slug_to_base_path(DetailedGuide, "slug")
      assert_equal "/government/collections/slug", document_type_and_slug_to_base_path(DocumentCollection, "slug")
      assert_equal "/government/fatalities/slug", document_type_and_slug_to_base_path(FatalityNotice, "slug")
      assert_equal "/government/news/slug", document_type_and_slug_to_base_path(NewsArticle, "slug")
      assert_equal "/government/fields-of-operation/slug", document_type_and_slug_to_base_path(OperationalField, "slug")
      assert_equal "/government/speeches/slug", document_type_and_slug_to_base_path(Speech, "slug")
      assert_equal "/government/statistical-data-sets/slug", document_type_and_slug_to_base_path(StatisticalDataSet, "slug")
      assert_equal "/government/statistics/announcements/slug", document_type_and_slug_to_base_path(StatisticsAnnouncement, "slug")
    end

    test "it defaults to generic edition slug if no explicit mapping found" do
      assert_equal "/government/generic-editions/slug", document_type_and_slug_to_base_path(Person, "slug")
    end

    test "it raises exception when trying to map a Publication and slug to a base path (not possible without knowing the PublicationType)" do
      error = assert_raises(RuntimeError) do
        document_type_and_slug_to_base_path(Publication, "slug")
      end

      assert_equal(
        "Ambiguous document type Publication. Its base path can vary depending on other factors. You cannot use the `document_type_and_slug_to_base_path` method.",
        error.message,
      )
    end
  end
end
