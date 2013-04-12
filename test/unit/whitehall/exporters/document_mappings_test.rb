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

    def assert_extraction(expected)
      actual = []
      @exporter.export(actual)
      assert_equal expected, arrays_to_csv(actual)
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
"",https://www.preview.alphagov.co.uk/government/publications/publication-title,301,publication-title,https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
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

    test "extracts supporting pages to csv" do
      supporting_page = create(:supporting_page)
      edition = supporting_page.edition
      assert_extraction_contains <<-EOT
"",https://www.preview.alphagov.co.uk/government/policies/#{edition.slug},418,#{edition.slug},https://whitehall-admin.test.alphagov.co.uk/government/admin/policies/#{edition.id},draft
"",https://www.preview.alphagov.co.uk/government/policies/#{edition.slug}/supporting-pages/#{supporting_page.slug},"","",https://whitehall-admin.test.alphagov.co.uk/government/admin/editions/#{supporting_page.edition_id}/supporting-pages/#{supporting_page.id},""
"",https://www.preview.alphagov.co.uk/government/policies/#{edition.slug}/supporting-pages/#{supporting_page.slug},"","",https://whitehall-admin.test.alphagov.co.uk/government/admin/editions/#{supporting_page.edition_id}/supporting-pages/#{supporting_page.id}/edit,""
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
      archived = create(:archived_news_article)
      assert_extraction_contains <<-EOF.strip_heredoc
        "",#{news_article_url(draft)},418,#{draft.slug},#{news_article_admin_url(draft)},#{draft.state}
        "",#{news_article_url(submitted)},418,#{submitted.slug},#{news_article_admin_url(submitted)},#{submitted.state}
        "",#{news_article_url(archived)},301,#{archived.slug},#{news_article_admin_url(archived)},#{archived.state}
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

    private

    def news_article_url(article)
      Rails.application.routes.url_helpers.news_article_url(article.slug, host: "www.preview.alphagov.co.uk", protocol: 'https')
    end

    def news_article_admin_url(article)
      Rails.application.routes.url_helpers.admin_news_article_url(article, host: "whitehall-admin.test.alphagov.co.uk", protocol: 'https')
    end
  end
end
