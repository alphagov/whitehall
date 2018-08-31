FactoryBot.define do
  factory :taxon_hash, class: Hash do
    transient do
      is_level_one_taxon { true }
      children { [] }
      visibility { true }
    end
    sequence("title") { |i| "Taxon Name #{i}" }
    sequence("base_path") { |i| "/path/to_taxon_#{i}" }
    sequence("content_id") { |i| "taxon_uuid_#{i}" }
    phase { 'live' }
    after :build do |hash, evaluator|
      hash["links"] = {
        "child_taxons" => evaluator.children
      }
      hash["details"] = {
        "visible_to_departmental_editors" => evaluator.visibility
      }
      hash.stringify_keys!
    end

    initialize_with { attributes }
  end
end
