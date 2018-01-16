# encoding: utf-8

require 'test_helper'

module Whitehall
  class MappingsTest < ActiveSupport::TestCase
    setup do
      @exporter = Whitehall::Exporters::Mappings.new
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
      assert_csv_contains <<-CSV.strip_heredoc
        Old URL,New URL,Admin URL,State
      CSV
    end

    test "excludes published publication without a Document Source" do
      publication = create(:published_publication)
      assert_csv_does_not_contain "http://admin.gov.uk/government/admin/publications/#{publication.id}"
    end

    test "handles documents without an edition" do
      document = create(:document)
      _source = create(:document_source, document: document, url: 'http://oldurl')
      assert_nothing_raised do
        @exporter.export([])
      end
    end

    test "includes published publication with a Document Source" do
      publication = create(:published_publication)
      _source = create(:document_source, document: publication.document, url: 'http://oldurl')

      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl,#{Whitehall.public_root}/government/publications/#{publication.slug},#{Whitehall.admin_root}/government/admin/publications/#{publication.id},published
      CSV
    end

    test "prefers published editions to newer works-in-progress" do
      document = create(:document)
      _source = create(:document_source, document: document, url: 'http://oldurl')
      published = create(:published_publication, document: document)
      _draft = create(:draft_publication, document: document)

      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl,#{Whitehall.public_root}/government/publications/#{published.slug},#{Whitehall.admin_root}/government/admin/publications/#{published.id},published
      CSV
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
        assert_csv_contains <<-CSV.strip_heredoc
          http://oldurl/#{state},#{Whitehall.public_root}/government/publications/#{publication.slug},#{Whitehall.admin_root}/government/admin/publications/#{publication.id},#{state}
        CSV
      end
    end

    test "excludes deleted documents" do
      # Rationale: this thing should never have been published
      publication = publication_with_source(:deleted)
      assert_csv_does_not_contain "#{Whitehall.public_root}/government/publications/#{publication.slug}"
    end

    test "includes withdrawn documents" do
      # Rationale: we should still redirect to things that were
      # published and then removed
      publication = publication_with_source(:withdrawn)
      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl/withdrawn,#{Whitehall.public_root}/government/publications/#{publication.slug},#{Whitehall.admin_root}/government/admin/publications/#{publication.id},withdrawn
      CSV
    end

    test "includes access limited editions" do
      # Rationale: we wouldn't redirect to this New URL, but it is still useful
      # to see that there is something being worked on relating to this Old URL
      publication = publication_with_source(:access_limited)
      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl/access_limited,#{Whitehall.public_root}/government/publications/#{publication.slug},#{Whitehall.admin_root}/government/admin/publications/#{publication.id},draft
      CSV
    end

    test "excludes superseded editions" do
      # A superseded edition should always have a newer edition that we would
      # look at, so this test is just belt-and-braces
      publication = publication_with_source(:superseded)
      assert_csv_does_not_contain publication.slug
    end

    test "includes a row per Document Source" do
      publication = create(:published_publication)
      create(:document_source, document: publication.document, url: 'http://oldurl1')
      create(:document_source, document: publication.document, url: 'http://oldurl2')
      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl1,#{Whitehall.public_root}/government/publications/#{publication.slug},#{Whitehall.admin_root}/government/admin/publications/#{publication.id},published
        http://oldurl2,#{Whitehall.public_root}/government/publications/#{publication.slug},#{Whitehall.admin_root}/government/admin/publications/#{publication.id},published
      CSV
    end

    test "excludes document sources with fabricated or placeholder URLs" do
      publication = create(:published_publication)
      create(:document_source, document: publication.document, url: 'http://oldurl1/fabricatedurl/foo')
      create(:document_source, document: publication.document, url: 'http://oldurl2/placeholderunique/1')
      create(:document_source, document: publication.document, url: 'http://oldurl3')

      assert_csv_does_not_contain 'oldurl1'
      assert_csv_does_not_contain 'oldurl2'
      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl3,#{Whitehall.public_root}/government/publications/#{publication.slug},#{Whitehall.admin_root}/government/admin/publications/#{publication.id},published
      CSV
    end

    test "attachment sources are included, without an admin URL" do
      attachment = create(:csv_attachment)
      create(:attachment_source, url: 'http://oldurl', attachment: attachment)
      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl,#{Whitehall.public_root}#{attachment.url},"",published
      CSV
    end

    test "excludes attachment sources with fabricated or placeholder URLs" do
      attachment = create(:csv_attachment)
      create(:attachment_source, url: 'http://oldurl1/fabricatedurl/foo', attachment: attachment)
      create(:attachment_source, url: 'http://oldurl2/placeholderunique/1', attachment: attachment)
      create(:attachment_source, url: 'http://oldurl3', attachment: attachment)

      assert_csv_does_not_contain 'oldurl1'
      assert_csv_does_not_contain 'oldurl2'
      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl3,#{Whitehall.public_root}#{attachment.url},"",published
      CSV
    end

    test "attachment sources use their visibility to populate 'State'" do
      edition = create(:publication, :draft)
      attachment = create(:csv_attachment, attachable: edition)
      attachment_source = create(:attachment_source, attachment: attachment)
      assert_csv_contains <<-CSV.strip_heredoc
        #{attachment_source.url},#{Whitehall.public_root}#{attachment.url},"",draft
      CSV
    end

    test "maps localised sources to localised New URLs in addition to the the default mapping" do
      publication = create(:published_publication)
      _source = create(:document_source, document: publication.document, url: 'http://oldurl/foo')
      _localised_source = create(:document_source, document: publication.document, url: 'http://oldurl/foo.es', locale: 'es')

      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl/foo,#{Whitehall.public_root}/government/publications/#{publication.slug},#{Whitehall.admin_root}/government/admin/publications/#{publication.id},published
        http://oldurl/foo.es,#{Whitehall.public_root}/government/publications/#{publication.slug}.es,#{Whitehall.admin_root}/government/admin/publications/#{publication.id},published
      CSV
    end

    test "an error exporting one document doesn't cause the whole export to fail" do
      problem_publication = create(:published_publication)
      create(:document_source, document: problem_publication.document, url: 'http://oldurl/problem')
      good_publication = create(:published_publication)
      create(:document_source, document: good_publication.document, url: 'http://oldurl/good')

      @exporter.expects(:document_url).twice.raises('Error!').then.returns('http://example.com/slug')

      assert_csv_contains <<-CSV.strip_heredoc
        http://oldurl/good,http://example.com/slug,#{Whitehall.admin_root}/government/admin/publications/#{good_publication.id},published
      CSV
    end
  end
end
