require 'test_helper'

class Taxonomy::TreeTest < ActiveSupport::TestCase
  test ".new sets the root_taxon property" do
    subject = Taxonomy::Tree.new(root_taxon_hash)
    assert subject.root_taxon.class == Taxonomy::Taxon
  end

  # Example of expanded links hash:
  #
  # {
  #   "links" => {
  #     "child_taxons" => [
  #       {
  #         "base_path" => "/root-path",
  #         "content_id" => "c58fdadd-7743-46d6-9629-90bb3ccc4ef0",
  #         "title" => "I am the root taxon.",
  #         "links" => {
  #           "child_taxons" => [
  #             {
  #               "base_path" => "/child-path",
  #               "content_id" =>"47b6ce42-0bfa-42ee-9ff1-7a9c71ee9727",
  #               "title" => "I am the child taxon.",
  #               "links" => {}
  #             }
  #           ]
  #         }
  #       }
  #     ]
  #   }
  # }

  test "it parses an empty set of child_taxons" do
    assert result("links" => {}).empty?
  end

  test "it parses a single child_taxon" do
    single_root_node = {
      "links" => {
        "child_taxons" => [
          node
        ]
      }
    }

    assert is_an_array_of_taxons result(single_root_node)
    assert result(single_root_node).length == 1
  end

  test "it parses two child_taxons" do
    two_root_nodes = {
      "links" => {
        "child_taxons" => [
          node,
          node
        ]
      }
    }

    assert is_an_array_of_taxons result(two_root_nodes)
    assert result(two_root_nodes).length == 2
  end

  test "it parses descendants of root node" do
    single_root_with_descendant = {
      "links" => {
        "child_taxons" => [
          node([node])
        ]
      }
    }

    assert result(single_root_with_descendant).length == 1
    assert is_an_array_of_taxons result(single_root_with_descendant).first.children
    assert result(single_root_with_descendant).first.children.length == 1
  end

  test "it sorts the taxon list alphabetically" do
    taxons = {
      "links" => {
        "child_taxons" => [
          node,
          node
        ]
      }
    }

    taxons["links"]["child_taxons"][0]["title"] = "zaphod"
    taxons["links"]["child_taxons"][1]["title"] = "allen"

    assert result(taxons).first.name == "allen"
    assert result(taxons).second.name == "zaphod"
  end

  def root_taxon_hash(links = {})
    @_root_taxon_hash ||= {
      'title' => 'root',
      'base_path' => '/root',
      'content_id' => 'root_id',
    }.merge(links)
  end

  def result(links = {})
    taxon_hash = root_taxon_hash(links)
    Taxonomy::Tree.new(taxon_hash).root_taxon.children
  end

  def is_an_array_of_taxons(arr)
    arr.is_a?(Array) && arr.all? { |el| el.is_a? Taxonomy::Taxon }
  end

  def node(children = [])
    node = {
      "base_path" => "/base-path",
      "content_id" => "content_id",
      "title" => "Taxon title",
      "phase" => "live",
      "details" => { "visible_to_departmental_editors" => true },
      "links" => {}
    }

    children.each do |child|
      node["links"]["child_taxons"] ||= []
      node["links"]["child_taxons"] << child
    end

    node
  end
end
