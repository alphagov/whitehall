require 'test_helper'

class Whitehall::DocumentFilter::DescriptionTest < ActiveSupport::TestCase

    test 'builds a human-readable description of a document filter using the filter drop-down texts' do
      publication_feed = "https://example.com/government/publications.atom?&departments%5B%5D=all&keywords=&official_document_status=all&publication_filter_option=closed-consultations&topics%5B%5D=all"
      description = Whitehall::DocumentFilter::Description.new(publication_feed)

      assert_match /closed consultations/, description.text
      assert_match /all departments/, description.text
      assert_match /all topics/, description.text
    end

    test 'properly describes department filters' do
      create(:ministerial_department, :with_published_edition, name: "Department of Health", slug: "department-of-health")
      publication_feed = 'http://example.com/government/publications.atom?&departments%5B%5D=department-of-health&keywords=&official_document_status=command_and_act_papers&publication_filter_option=all&topics%5B%5D=all'
      description = Whitehall::DocumentFilter::Description.new(publication_feed)

      assert_match /Department of Health/, description.text
    end
    end

end
