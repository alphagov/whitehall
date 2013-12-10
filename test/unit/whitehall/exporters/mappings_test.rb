# encoding: utf-8
require 'test_helper'

module Whitehall
  class MappingsTest < ActiveSupport::TestCase
    setup do
      @exporter = Whitehall::Exporters::Mappings.new('test')
      ENV['FACTER_govuk_platform'] = 'preview'
    end

    def arrays_to_csv(arrays)
      CSV.generate do |csv|
        arrays.each do |array|
          csv << array
        end
      end
    end

    def assert_extraction(expected, row_skip_predicate=nil)
      actual = []
      @exporter.export(actual)
      assert_equal expected, arrays_to_csv(actual.reject(&row_skip_predicate))
    end

    def assert_extraction_contains(expected)
      actual = []
      @exporter.export(actual)
      actual = arrays_to_csv(actual)
      assert actual.include?(expected.strip), "Expected:\n#{actual} to contain: \n#{expected}"
    end

    def assert_extraction_does_not_contain(unexpected)
      actual = []
      @exporter.export(actual)
      actual = arrays_to_csv(actual)
      refute actual.include?(unexpected.strip), "Expected:\n#{actual} to NOT contain: \n#{unexpected}"
    end

    test "headers" do
      assert_extraction_contains <<-EOT.strip_heredoc
        Old URL,New URL,Admin URL,State
      EOT
    end

    test "excludes published publication without a Document Source" do
      publication = create(:published_publication)
      assert_extraction_does_not_contain "https://admin.gov.uk/government/admin/publications/#{publication.id}"
    end

    test "includes published publication with a Document Source" do
      publication = create(:published_publication)
      source = create(:document_source, document: publication.document, url: 'http://oldurl')

      assert_extraction_contains <<-EOT.strip_heredoc
        http://oldurl,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
      EOT
    end

    test "includes a row per Document Source for published publication" do
      publication = create(:published_publication)
      source1 = create(:document_source, document: publication.document, url: 'http://oldurl1')
      source2 = create(:document_source, document: publication.document, url: 'http://oldurl2')
      assert_extraction_contains <<-EOT.strip_heredoc
        http://oldurl1,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
        http://oldurl2,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
      EOT
    end
  end
end
