require 'test_helper'

module Whitehall::DocumentFilter
  class AdvancedSearchRummagerTest < ActiveSupport::TestCase
    setup do
      Whitehall.government_search_client.stubs(:advanced_search).returns {}
    end

    def format_types(*classes)
      classes.map(&:search_format_type)
    end

    def expect_search_by_format_types(format_types)
      Whitehall
        .government_search_client
        .expects(:advanced_search)
        .with(
          has_entry(
            search_format_types: format_types
          )
        )
    end

    def expect_search_by_taxonomy_tree(taxons)
      Whitehall
          .government_search_client
          .expects(:advanced_search)
          .with(
            has_entry(
              part_of_taxonomy_tree: taxons
            )
          )
    end

    def expect_search_by_people(people)
      Whitehall
        .government_search_client
        .expects(:advanced_search)
        .with(
          has_entry(people: people)
        )
    end

    test 'publications_search looks for Publications, Consultations, and StatisticalDataSets by default' do
      rummager = AdvancedSearchRummager.new({})
      expect_search_by_format_types(format_types(Consultation, Publication, StatisticalDataSet))
      rummager.publications_search
    end

    test 'publications_search looks for a specific announcement sub type if we use the publication_type option' do
      rummager = AdvancedSearchRummager.new(publication_type: 'policy-papers')
      expect_search_by_format_types(PublicationType::PolicyPaper.search_format_types)
      rummager.publications_search
    end

    test 'publications_search search the taxonomy tree if we use the taxons option' do
      rummager = AdvancedSearchRummager.new(taxons: 'content-id')
      expect_search_by_taxonomy_tree(%w[content-id])
      rummager.publications_search
    end
  end
end
