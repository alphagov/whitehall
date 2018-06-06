require 'test_helper'

class Taxonomy::MappingTest < ActiveSupport::TestCase
  setup do
    Taxonomy::TopicTaxonomy
      .any_instance
      .stubs(:all_taxons)
      .returns(all_taxons)
  end

  test "legacy_mapping_for_taxon with a direct mapping" do
    result = Taxonomy::Mapping.new.legacy_mapping_for_taxon(
      test_taxon_with_direct_mapping.content_id
    )

    assert_equal result.dig("policy_area", 0, "title"), "Test Policy Area"
  end

  test "legacy_mapping_for_taxon with a indirect mapping" do
    result = Taxonomy::Mapping.new.legacy_mapping_for_taxon(
      test_taxon_with_indirect_mapping.content_id
    )

    assert_equal result.dig("policy_area", 0, "title"), "Test Policy Area"
  end

  test "legacy_mapping_for_taxons" do
    result = Taxonomy::Mapping.new.legacy_mapping_for_taxons(
      [
        test_taxon_with_direct_mapping.content_id,
        test_taxon_with_multiple_legacy_taxons.content_id
      ]
    )

    assert_equal 2, result.length
    assert_same_elements(
      ["Test Policy Area", "Test legacy policy"],
      result.map { |x| x["title"] }
    )
  end

  def all_taxons
    [
      test_taxon_with_direct_mapping,
      test_taxon_with_indirect_mapping,
      test_taxon_with_multiple_legacy_taxons
    ]
  end

  def test_taxon_with_direct_mapping
    Taxonomy::Taxon.new(
      title: "Direct mapping",
      base_path: "/direct-mapping",
      content_id: "341b0937-8590-47d6-8fa6-3203e162ec93",
      legacy_mapping: {
        "policy_area" => [
          {
            "content_id" => "35baa314-9f31-4276-bad2-30bba3f40975",
            "title" => "Test Policy Area"
          }
        ]
      }
    )
  end

  def test_taxon_with_indirect_mapping
    taxon = Taxonomy::Taxon.new(
      title: "Indirect mapping",
      base_path: "/indirect-mapping",
      content_id: "e8ff7b4a-08af-4750-bd1b-6cd0b9fee04a",
      legacy_mapping: {},
    )

    taxon.parent_node = test_taxon_with_direct_mapping

    taxon
  end

  def test_taxon_with_multiple_legacy_taxons
    Taxonomy::Taxon.new(
      title: "Multiple legacy",
      base_path: "/multiple-legacy",
      content_id: "bb5fbd37-0b75-4f90-8a24-b19d1d8b16f4",
      legacy_mapping: {
        "policy_area" => [
          {
            "content_id" => "35baa314-9f31-4276-bad2-30bba3f40975",
            "title" => "Test Policy Area"
          }
        ],
        "policy" => [
          {
            "content_id" => "40911228-459d-4568-8199-c2d921f5388f",
            "title" => "Test legacy policy"
          }
        ]
      }
    )
  end
end
