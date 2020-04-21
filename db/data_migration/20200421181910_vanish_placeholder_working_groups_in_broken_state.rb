broken_group_content_ids = Services.publishing_api.lookup_content_ids(
  base_paths: ["/government/groups/funding-external-technical-advisory-group",
               "/government/groups/military-stabilisation-support-group"],
).values

broken_group_content_ids.each do |content_id|
  PublishingApiVanishWorker.perform_async(content_id, "en", discard_drafts: true)
end
