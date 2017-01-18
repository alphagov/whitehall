en_content_ids_to_discard = [
  "d3f8dbac-ea2e-4b66-9935-98e8e25e7568",
  "95dee412-edf7-4a72-b607-b6ca9afa8470",
  "e7c2b9da-bb69-4cff-acb9-4ea2e5825c79",
  "5d7c2910-d7c8-4d7b-9fa4-280f108c7a86",
  "afab1e76-592c-468f-ab67-4c54020022a9",
]

en_content_ids_to_discard.each do |content_id|
  PublishingApiDiscardDraftWorker.perform_async(content_id, "en")
end
