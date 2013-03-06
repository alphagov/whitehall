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
  end
end
