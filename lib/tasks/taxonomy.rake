require 'redis-lock'

namespace :taxonomy do
  task rebuild_cache: [:environment] do
    Redis.current.lock("rebuild_taxonomy_cache_worker_lock", life: 10.minutes, acquire: 1) do
      Rails.logger.info "Scheduling taxonomy cache rebuild"
      RebuildTaxonomyCacheWorker.perform_async
    end
  end

  task populate_end_to_end_test_data: [:environment] do
    taxon_content_id = SecureRandom.uuid
    taxon_payload = {
      base_path: "/test_taxon",
      document_type: "taxon",
      schema_name: "taxon",
      title: "Test taxon",
      description: "Test taxon description",
      publishing_app: "content-tagger",
      rendering_app: "collections",
      public_updated_at: Time.now.iso8601,
      locale: "en",
      details: {
        internal_name: "Test taxon",
        visible_to_departmental_editors: true,
      },
      routes: [
        { path: "/test_taxon", type: "exact" },
      ],
      update_type: "major",
      phase: "live",
    }

    root_taxon_content_id = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a"
    taxon_links = {
      links: {
        root_taxon: [root_taxon_content_id]
      }
    }

    Services.publishing_api.put_content(taxon_content_id, taxon_payload)
    Services.publishing_api.patch_links(taxon_content_id, taxon_links)
    Services.publishing_api.publish(taxon_content_id, nil, locale: "en")
  end
end
