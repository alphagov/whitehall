FactoryBot.define do
  factory :taxon_hash, class: Hash do
    transient do
      is_level_one_taxon true
      children []
      visibility true
    end
    sequence("title") { |i| "Taxon Name #{i}" }
    sequence("base_path") { |i| "/path/to_taxon_#{i}" }
    sequence("content_id") { |i| "taxon_uuid_#{i}" }
    phase 'live'
    after :build do |hash, evaluator|
      if evaluator.is_level_one_taxon
        hash["expanded_links_hash"] = {
          "expanded_links" => {
            "child_taxons" => evaluator.children
          }
        }
      else
        hash["links"] = {
            "child_taxons" => evaluator.children
        }
      end
      hash["details"] = {
        "visible_to_departmental_editors" => evaluator.visibility
      }
      hash.stringify_keys!
    end

    initialize_with { attributes }
  end
end
