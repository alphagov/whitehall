require 'test_helper'
require './lib/taxonomy'

module Taxonomy
  class FindChildestTest < ActiveSupport::TestCase
    include EducationTaxonomyHelper

    test '#taxons, returns childest taxons in a tree' do
      stub_education_taxonomy

      selected_taxons = %w(
        7c75c541-403f-4cb1-9b34-4ddde816a80d
        904cfd73-2707-47b8-8754-5765ec5a5b68
        07fdd985-f3ec-4f4e-a316-3f4fd491bd64
      )

      expected_taxons = ["07fdd985-f3ec-4f4e-a316-3f4fd491bd64"]

      childest_taxons = FindChildest.new(
        tree: Taxonomy.education.tree,
        selected_taxons: selected_taxons
      ).taxons

      assert_equal childest_taxons, expected_taxons
    end
  end
end
