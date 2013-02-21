require 'test_helper'

module Whitehall
  class DocumentMappingsTest < ActiveSupport::TestCase
    setup do
      @exporter = Whitehall::Exporters::DocumentMappings.new('test')
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

    test "extract published publication to csv" do
      publication = create(:published_publication)
      assert_extraction <<-EOT
Old Url,New Url,Status,Whole Tag,Slug,Admin Url,State
"",https://www.preview.alphagov.co.uk/government/publications/publication-title,301,Closed,publication-title,https://whitehall-admin.test.alphagov.co.uk/government/admin/publications/#{publication.id},published
"",https://www.preview.alphagov.co.uk/government/organisations/organisation-1,"","","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/organisation-1,""
"",https://www.preview.alphagov.co.uk/government/organisations/organisation-1,"","","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/organisation-1/edit,""
      EOT
    end

    test "extracts corporate information pages to csv" do
      corporate_information_page = create(:corporate_information_page)
      organisation = Organisation.last
      assert_extraction <<-EOT
Old Url,New Url,Status,Whole Tag,Slug,Admin Url,State
"",https://www.preview.alphagov.co.uk/government/organisations/#{organisation.slug},"","","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/#{organisation.slug},""
"",https://www.preview.alphagov.co.uk/government/organisations/#{organisation.slug},"","","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/#{organisation.slug}/edit,""
"",https://www.preview.alphagov.co.uk/government/organisations/#{organisation.slug}/about/publication-scheme,"","","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/#{organisation.slug}/corporate_information_pages/publication-scheme,""
"",https://www.preview.alphagov.co.uk/government/organisations/#{organisation.slug}/about/publication-scheme,"","","",https://whitehall-admin.test.alphagov.co.uk/government/admin/organisations/#{organisation.slug}/corporate_information_pages/publication-scheme/edit,""
      EOT
    end
  end
end
