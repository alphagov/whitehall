cy_content_ids_to_discard = [
  "f7061c7c-8a31-4738-8c6c-5340fab21787",
  "1844805b-83b4-4716-b996-af23617f1182",
  "ed2bf672-e074-46d1-9022-f07cd6242105",
  "129e6e50-4dee-4f77-861a-0813c43f84de",
  "b4156dbd-62a7-47eb-9012-b87ec930fd65",
]

cy_content_ids_to_discard.each do |content_id|
  PublishingApiDiscardDraftWorker.perform_async(content_id, "cy")
end

en_content_ids_to_discard = [
  "d3f8dbac-ea2e-4b66-9935-98e8e25e7568",
  "95dee412-edf7-4a72-b607-b6ca9afa8470",
  "e7c2b9da-bb69-4cff-acb9-4ea2e5825c79",
  "5d7c2910-d7c8-4d7b-9fa4-280f108c7a86",
  "afab1e76-592c-468f-ab67-4c54020022a9",
]

en_content_ids_to_discard.each do |content_id|
  PublishingApiDiscardDraftWorker.perform_async(content_id, "cy")
end
