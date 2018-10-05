namespace :policy_area do
  desc 'Remove and redirect policy areas'
  task :remove_and_redirect, %i(policy_areas_path) => :environment do |_t, args|
    args.with_defaults(
      policy_areas_path: 'tmp/policy_areas.json', # [{ policy_area_path: ...,  taxon_path: ...}]
    )
    policy_area_hashes = JSON.parse(File.read(args[:policy_areas_path]), symbolize_names: true)
    policy_area_hashes.each do |policy_area_hash|
      content_item = Whitehall.content_store.content_item(policy_area_hash.fetch(:policy_area_path)).to_h
      taxon_content_item = Whitehall.content_store.content_item(policy_area_hash.fetch(:taxon_path)).to_h
      if content_item.fetch('document_type') != 'placeholder_policy_area' &&
          content_item.fetch('document_type') != 'policy_area'
        raise "not a policy area"
      end
      if taxon_content_item.fetch('document_type') != 'taxon'
        raise 'redirect is not a taxon'
      end
      puts "Unpublishing policy area: #{policy_area_hash.fetch(:policy_area_path)} - #{content_item.fetch('content_id')} - redirect to: #{policy_area_hash.fetch(:taxon_path)}"
      policy_area = Topic.find_by(content_id: content_item.fetch('content_id'))
      policy_area.unpublish_and_redirect(policy_area_hash.fetch(:taxon_path))
    end
  end
end
