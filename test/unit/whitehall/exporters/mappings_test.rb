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

    def assert_csv_contains(expected)
      actual = []
      @exporter.export(actual)
      actual = arrays_to_csv(actual)
      assert actual.include?(expected.strip), "Expected:\n#{actual} to contain: \n#{expected}"
    end

    def assert_csv_does_not_contain(unexpected)
      actual = []
      @exporter.export(actual)
      actual = arrays_to_csv(actual)
      refute actual.include?(unexpected.strip), "Expected:\n#{actual} to NOT contain: \n#{unexpected}"
    end

    def publication_with_source(publication_trait)
      publication = create(:publication, publication_trait)
      create(:document_source, document: publication.document, url: "http://oldurl/#{publication_trait}")
      publication
    end

    test "headers" do
      assert_csv_contains <<-EOT.strip_heredoc
        Old URL,New URL,Admin URL,State
      EOT
    end

    test "excludes published publication without a Document Source" do
      publication = create(:published_publication)
      assert_csv_does_not_contain "https://admin.gov.uk/government/admin/publications/#{publication.id}"
    end

    test "handles documents without an edition" do
      document = create(:document)
      source = create(:document_source, document: document, url: 'http://oldurl')
      assert_nothing_raised do
        @exporter.export([])
      end
    end

    test "includes published publication with a Document Source" do
      publication = create(:published_publication)
      source = create(:document_source, document: publication.document, url: 'http://oldurl')

      assert_csv_contains <<-EOT.strip_heredoc
        http://oldurl,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
      EOT
    end

    test "prefers published editions to newer works-in-progress" do
      document = create(:document)
      source = create(:document_source, document: document, url: 'http://oldurl')
      published = create(:published_publication, document: document)
      draft = create(:draft_publication, document: document)

      assert_csv_contains <<-EOT.strip_heredoc
        http://oldurl,https://www.preview.alphagov.co.uk/government/publications/#{published.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{published.id},published
      EOT
    end

    test "includes works-in-progress with a Document Source" do
      publications = {
        'imported'  => publication_with_source(:imported),
        'draft'     => publication_with_source(:draft),
        'submitted' => publication_with_source(:submitted),
        'rejected'  => publication_with_source(:rejected),
        'scheduled' => publication_with_source(:scheduled),
      }
      publications.each do |state, publication|
        assert_csv_contains <<-EOT.strip_heredoc
          http://oldurl/#{state},https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},#{state}
        EOT
      end
    end

    test "excludes deleted documents" do
      # Rationale: this thing should never have been published
      publication = publication_with_source(:deleted)
      assert_csv_does_not_contain "https://www.preview.alphagov.co.uk/government/publications/#{publication.slug}"
    end

    test "includes archived documents" do
      # Rationale: we should still redirect to things that were
      # published and then removed
      publication = publication_with_source(:archived)
      assert_csv_contains <<-EOT.strip_heredoc
        http://oldurl/archived,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},archived
      EOT
    end

    test "includes access limited editions" do
      # Rationale: we wouldn't redirect to this New URL, but it is still useful
      # to see that there is something being worked on relating to this Old URL
      publication = publication_with_source(:access_limited)
      assert_csv_contains <<-EOT.strip_heredoc
        http://oldurl/access_limited,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},draft
      EOT
    end

    test "excludes superseded editions" do
      # A superseded edition should always have a newer edition that we would
      # look at, so this test is just belt-and-braces
      publication = publication_with_source(:superseded)
      assert_csv_does_not_contain publication.slug
    end

    test "includes a row per Document Source" do
      publication = create(:published_publication)
      source1 = create(:document_source, document: publication.document, url: 'http://oldurl1')
      source2 = create(:document_source, document: publication.document, url: 'http://oldurl2')
      assert_csv_contains <<-EOT.strip_heredoc
        http://oldurl1,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
        http://oldurl2,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
      EOT
    end

    test "attachment sources are included, without an admin URL" do
      attachment = create(:csv_attachment)
      attachment_source = create(:attachment_source, url: 'http://oldurl', attachment: attachment)
      assert_csv_contains <<-EOT.strip_heredoc
        http://oldurl,https://www.preview.alphagov.co.uk#{attachment.url},"",published
      EOT
    end

    test "maps localised sources to localised New URLs in addition to the the default mapping" do
      publication = create(:published_publication)
      source = create(:document_source, document: publication.document, url: 'http://oldurl/foo')
      localised_source = create(:document_source, document: publication.document, url: 'http://oldurl/foo.es', locale: 'es')

      assert_csv_contains <<-EOT.strip_heredoc
        http://oldurl/foo,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
        http://oldurl/foo.es,https://www.preview.alphagov.co.uk/government/publications/#{publication.slug}.es,https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
      EOT
    end

    test "an error exporting one document doesn't cause the whole export to fail" do
      problem_publication = create(:published_publication)
      create(:document_source, document: problem_publication.document, url: 'http://oldurl/problem')
      good_publication = create(:published_publication)
      create(:document_source, document: good_publication.document, url: 'http://oldurl/good')

      @exporter.expects(:document_url).twice.raises('Error!').then.returns('http://example.com/slug')

      assert_csv_contains <<-EOT.strip_heredoc
        http://oldurl/good,http://example.com/slug,https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{good_publication.id},published
      EOT
    end
  end
end
