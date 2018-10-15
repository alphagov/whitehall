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

    assert_equal "Test Specialist Sector", result.dig("topic", 0, "title")
  end

  test "legacy_mapping_for_taxon with a indirect mapping" do
    result = Taxonomy::Mapping.new.legacy_mapping_for_taxon(
      test_taxon_with_indirect_mapping.content_id
    )

    assert_equal "Test Specialist Sector", result.dig("topic", 0, "title")
  end

  test "legacy_mapping_for_taxons" do
    result = Taxonomy::Mapping.new.legacy_mapping_for_taxons(
      all_taxons.map(&:content_id)
    )

    assert_equal 2, result.length
    assert_same_elements(
      ["Test Specialist Sector", "Another Test Specialist Sector"],
      result.map { |x| x["title"] }
    )
  end

  def all_taxons
    [
      test_taxon_with_direct_mapping,
      test_taxon_with_indirect_mapping,
      another_test_taxon_with_direct_mapping
    ]
  end

  def test_taxon_with_direct_mapping
    Taxonomy::Taxon.new(
      title: "Direct mapping",
      base_path: "/direct-mapping",
      content_id: "341b0937-8590-47d6-8fa6-3203e162ec93",
      legacy_mapping: {
        "topic" => [
          {
            "content_id" => "35baa314-9f31-4276-bad2-30bba3f40975",
            "title" => "Test Specialist Sector"
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

  def another_test_taxon_with_direct_mapping
    Taxonomy::Taxon.new(
      title: "Direct mapping",
      base_path: "/direct-mapping",
      content_id: "59d39ef3-2d6d-4b38-8d8b-37c0d0390a29",
      legacy_mapping: {
        "topic" => [
          {
            "content_id" => "e2aa4b5a-60d1-40c8-a1fd-ae94ee469efc",
            "title" => "Another Test Specialist Sector"
          }
        ]
      }
    )
  end
end
