# encoding: utf-8
require 'test_helper'

module Whitehall
  class DocumentMappingsTest < ActiveSupport::TestCase
    setup do
      @exporter = Whitehall::Exporters::DocumentMappings.new('test')
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

    test "extract published publication to csv" do
      publication = create(:published_publication)
      organisation = publication.organisations.first
      assert_extraction <<-EOT
Old Url,New Url,Status,Slug,Admin Url,State
"",https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},301,#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
"",https://www.preview.alphagov.co.uk/government/organisations/#{organisation.slug},"","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/#{organisation.slug},""
"",https://www.preview.alphagov.co.uk/government/organisations/#{organisation.slug},"","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/#{organisation.slug}/edit,""
      EOT
    end

    test "extract consultations (with source) to csv" do
      article = create(:published_consultation)
      source = create(:document_source, document: article.document)

      assert_extraction_contains <<-EOT
#{source.url},https://www.preview.alphagov.co.uk/government/consultations/consultation-title,301,consultation-title,https://whitehall-admin.test.alphagov.co.uk/government/admin/consultations/#{article.id},published
      EOT
    end

    test "extracts corporate information pages to csv" do
      corporate_information_page = create(:corporate_information_page)
      organisation = Organisation.last
      assert_extraction <<-EOT
Old Url,New Url,Status,Slug,Admin Url,State
"",https://www.preview.alphagov.co.uk/government/organisations/#{organisation.slug},"","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/#{organisation.slug},""
"",https://www.preview.alphagov.co.uk/government/organisations/#{organisation.slug},"","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/#{organisation.slug}/edit,""
"",https://www.preview.alphagov.co.uk/government/organisations/#{organisation.slug}/about/publication-scheme,"","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/#{organisation.slug}/corporate_information_pages/publication-scheme/edit,""
      EOT
    end

    test "exports multiple document sources" do
      article = create(:news_article)
      source_1 = create(:document_source, document: article.document)
      source_2 = create(:document_source, document: article.document)

      assert_extraction_contains <<-EOF.strip_heredoc
        #{source_1.url},#{news_article_url(article)},418,#{article.slug},#{news_article_admin_url(article)},#{article.state}
        #{source_2.url},#{news_article_url(article)},418,#{article.slug},#{news_article_admin_url(article)},#{article.state}
      EOF
    end

    test "exports non published editions with 418s" do
      draft = create(:draft_news_article)
      submitted = create(:submitted_news_article)
      published = create(:published_news_article)
      assert_extraction_contains <<-EOF.strip_heredoc
        "",#{news_article_url(draft)},418,#{draft.slug},#{news_article_admin_url(draft)},#{draft.state}
        "",#{news_article_url(submitted)},418,#{submitted.slug},#{news_article_admin_url(submitted)},#{submitted.state}
        "",#{news_article_url(published)},301,#{published.slug},#{news_article_admin_url(published)},#{published.state}
      EOF
    end

    test "exports with 301 if the document has a published edition" do
      publication = create(:published_publication)
      new_draft = publication.create_draft(create(:gds_editor))
      assert_extraction_contains <<-EOF.strip_heredoc
        "",https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},301,#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
        "",https://www.preview.alphagov.co.uk/government/publications/#{publication.slug},301,#{publication.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{new_draft.id},draft
      EOF
    end

    test "exports with 301 to the original slug of an unpublished edition" do
      publication = create(:published_publication)
      old_slug = publication.document.slug
      unpublishing = publication.unpublishing = create(:unpublishing)
      Whitehall.edition_services.unpublisher(publication).perform!
      publication.title = "This is a new title"
      publication.save!
      refute_equal old_slug, publication.document.slug
      assert_extraction_contains <<-EOF.strip_heredoc
        "",https://www.preview.alphagov.co.uk/government/publications/#{unpublishing.slug},301,#{unpublishing.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},draft
      EOF
    end

    test "exports documents with translated sources points to localised version" do
      article = create(:news_article)
      translation_source = create(:document_source, document: article.document, locale: 'es')
      source = create(:document_source, document: article.document)

      assert_extraction_contains <<-EOF.strip_heredoc
        #{translation_source.url},#{news_article_url(article)}.es,418,#{article.slug},#{news_article_admin_url(article)},#{article.state}
        #{source.url},#{news_article_url(article)},418,#{article.slug},#{news_article_admin_url(article)},#{article.state}
      EOF
    end

    test "an error exporting an edition doesn't cause the whole export to fail" do
      article1 = create(:published_worldwide_priority)
      article2 = create(:published_news_article)
      @exporter.stubs(:document_url_and_slug).raises("Error!").then.returns(["http://example.com/slug", "slug"])

      expected = <<-EOT
Old Url,New Url,Status,Slug,Admin Url,State
"",http://example.com/slug,301,slug,https://whitehall-admin.test.alphagov.co.uk/government/admin/news/#{article2.id},published
      EOT
      assert_extraction expected, ->(row) { row.any? {|cell| cell =~ /organisation/ } }
    end

    test "attachment sources are included" do
      attachment_source = create(:attachment_source)
      assert_extraction_contains <<-EOT
Old Url,New Url,Status,Slug,Admin Url,State
#{attachment_source.url},https://www.preview.alphagov.co.uk#{attachment_source.attachment.url},301,"","","",Closed
      EOT
    end

    test "attachment sources are not included if they lack an attachment" do
      attachment_source = create(:attachment_source, attachment: nil)
      assert_extraction <<-EOT
Old Url,New Url,Status,Slug,Admin Url,State
      EOT
    end

    private

    def news_article_url(article)
      Rails.application.routes.url_helpers.news_article_url(article.slug, host: "www.preview.alphagov.co.uk", protocol: 'https')
    end

    def news_article_admin_url(article)
      Rails.application.routes.url_helpers.admin_news_article_url(article, host: "whitehall-admin.test.alphagov.co.uk", protocol: 'https')
    end
  end
end
