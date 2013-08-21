# encoding: UTF-8
require 'fast_test_helper'
require 'whitehall/uploader'

module Whitehall::Uploader
  class CaseStudyRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub('Organisation')
    end

    test "validates row headings" do
      assert_equal [], Whitehall::Uploader::CaseStudyRow.heading_validation_errors(basic_headings)
    end

    test "validates a complete set of row headings" do
      complete_row_headings = basic_headings + %w(document_series_2 document_series_3 document_series_4 policy_2 policy_3 policy_4)
      assert_equal [], Whitehall::Uploader::CaseStudyRow.heading_validation_errors(complete_row_headings)
    end

    test "ignores ignored fields" do
      assert_equal [], Whitehall::Uploader::CaseStudyRow.heading_validation_errors(basic_headings + %w(ignore_this ignore_this_too))
    end

    test "finds document series by slug in document_series_n column" do
      doc_series_1 = create(:document_series)
      doc_series_2 = create(:document_series)
      row = case_study_row({"document_series_1" => doc_series_1.slug, "document_series_2" => doc_series_2.slug})
      row.stubs(:organisation).returns(stubbed_organisation)
      assert_equal [doc_series_1, doc_series_2], row.document_series
    end

    test "finds policies by slug in policy_n column" do
      policy_1 = create(:policy)
      policy_2 = create(:policy)
      row = case_study_row({"policy_1" => policy_1.slug, "policy_2" => policy_2.slug})
      row.stubs(:organisation).returns(stubbed_organisation)
      assert_equal [policy_1, policy_2], row.attributes[:related_editions]
    end

    test "parses first published column" do
      row = case_study_row("first_published" => "11-Jan-2011")
      row.stubs(:organisation).returns(stubbed_organisation)
      assert_equal Time.zone.parse("2011-01-11"), row.attributes[:first_published_at]
    end

    test "returns lead_organisations as an attribute" do
      organisation = stubbed_organisation
      row = case_study_row({})
      row.stubs(:organisations).returns([organisation])
      assert_equal [organisation], row.lead_organisations
    end

    private

    def basic_headings
      %w(old_url title summary body organisation document_series_1 policy_1 first_published)
    end

    def case_study_row(data)
      CaseStudyRow.new(data, 1, @attachment_cache, @default_organisation)
    end

    private

    def stubbed_organisation
      stub("organisation", url: "url")
    end
  end
end
