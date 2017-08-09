namespace :worldwide_pages do
  desc "redirect world locations from /government/world/* to /world/*"
  task redirect_world_locations: :environment do
    # We need to create new content items here so that they don't overwrite the
    # existing content items in the PublishingApi as those are still required
    # for tagging
    WorldLocation.countries.each do |wl|
      content_id = SecureRandom.uuid

      redirect_payload = {
        schema_name: "redirect",
        document_type: "redirect",
        base_path: "/government/world/#{wl.slug}",
        publishing_app: "whitehall",
        redirects: [
          {
            "path" => "/government/world/#{wl.slug}",
            "type" => "exact",
            "destination" => "/world/#{wl.slug}",
          }
        ],
      }

      Services.publishing_api.put_content(content_id, redirect_payload)
      Services.publishing_api.publish(content_id, "major")

      # Remove duplicate entries from Rummager
      SearchIndexDeleteWorker.perform_async_in_queue(
        "bulk_republishing",
        "/government/world/#{wl.slug}",
        wl.rummager_index
      )
    end
  end
end
