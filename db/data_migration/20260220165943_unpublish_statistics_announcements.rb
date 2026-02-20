# Statistics Announcements are supposed to automatically unpublish when their associated publication goes live, but some have been left in a published state. This migration unpublishes those announcements and republishes them as redirects to the associated publication.
statistics_announcements_with_live_publications = %w[
  10309
  15398
  21452
  22029
  29850
  31302
  31304
  31306
  34033
  34379
  35397
  35401
  35404
  36981
  37848
  37856
  38304
  38968
  39407
  39409
  39410
  39412
  39922
  39923
  40184
  42494
].map { |id| StatisticsAnnouncement.find(id) }

statistics_announcements_with_live_publications.each do |sa|
  Whitehall::PublishingApi.publish_redirect_async(sa.content_id, sa.publication.base_path)
rescue StandardError => e
  puts "Failed to publish redirect for #{sa.content_id}: #{e.message}"
end

# The following content_ids are for statistics announcements that have been deleted, but not unpublished. We want to unpublish these and publish redirects to the statistics announcements index page.
deleted_statistics_announcements = %w[
  6c9658b0-1ade-466c-be91-f21952c9e241
  e1b733a6-58c4-4033-8fd7-a10b3eaccc92
  4432942e-73f6-4386-adae-a267975e57a9
  d02c9931-4fc8-4208-8578-9762c75e86a2
  d0627c25-1630-4528-afe9-7d9a4670a19d
  2c356e4f-c1b9-4379-bf47-68961d66e154
  1dbd09a3-71ec-4791-9aad-39b9a0999f6f
  da924118-6bb0-4005-a756-3ea9d5216b09
  15b129a3-3198-4c04-a32c-7f355c69572a
  192167a4-415f-49a7-9fac-4cc3292329a0
  3fcc2917-d57c-44e8-ba81-623019b140cb
  b053bff0-e0eb-4b4d-80d1-11593a448d95
  974151ec-51c1-4072-a2e2-e14d986ddd71
  b740a4ff-08cc-410a-90de-66d9e262e9c8
  8a4a047d-e1c2-48f5-a9d7-006026f9225f
  b46bc961-6193-4a87-a469-70e9fe71c5c1
  d3e9394a-6f5d-44eb-8a5c-3ff2465dd2fb
  a667ffa7-c442-4eb0-a519-87ba387bef9e
  716b1ae2-574e-4c93-8e3a-b903b24a09d6
  d41d4b97-fa80-4643-a9be-c1788de36c99
  5ed0aca2-929f-45a4-8069-99d140c08e8f
  bd0d2720-93c5-4b5a-9f8a-8f59284aa786
  61470eda-26dc-478a-979d-83fe7ad63664
  7f0e17ca-384d-43b6-a4fc-d005407366c7
  324b8a82-d35c-4bfc-abfd-049f510fc6af
  7be547c6-65b2-4597-ac08-b1fbe933c7fd
  b4299188-9be7-41a1-bdd4-fd937575e2b7
  0a7241dd-3a10-4621-833f-91b1797e3033
  1d905586-21e6-443a-8410-e9b9a7307130
  e2b82ccc-569b-4907-8e78-086bd042d369
  4a5db7bd-51f0-401f-9419-92367e835c70
  bd630b23-f46c-428a-b729-54cf238e7763
  1b2a40bd-9de8-4e86-8c64-75580daf1283
  72d56466-3c7e-47f8-b781-27839e51260d
  6058cc52-f8e4-4de5-b8e4-c93a2c05dcd5
  a1935644-cdfa-43a9-91c0-aa683adc86cf
  6150bd56-73c8-4ed7-a509-76152d7165a6
  5ff0aa25-5b02-4c16-856e-e8f0dd500790
  df347baa-71c4-4c76-8143-9efb6bdfed47
  2380e867-3c74-46d7-ad5c-c73fef80ae47
  e4a71c5a-d0bb-4eef-8f93-b4816d72e55a
  05f7425e-7118-4c7f-b8c8-10fdbf94bda2
  10733c75-1d1c-4083-9425-3415363b21e7
  2c33c298-2226-4c3c-8d8d-96d133f9c34c
  d6787983-7e8a-4026-b932-b884d4380ab1
  02a6ca7a-c0df-41c4-ac0e-9d7206707c7a
  a5f871a3-86bd-4fc5-9bcc-fb3b1b789230
  03ee1c25-da1b-4f3d-a2a6-f7f0f1c10ddd
  0b466ac8-d35f-4a78-9a5f-b5da1102d7e4
  0c40be40-48d7-43ca-b641-51e32b6709fe
  176793db-fc59-4bd4-9736-bb75c9099b2f
  18a331f2-29a2-4a8c-a09a-2d29d9b0dc17
  9aba1041-fb60-452b-b126-79154cdb5152
  1305ded7-857d-4d85-9801-c04919239a37
  dd499834-04cc-457e-afd3-86dfd8c1188b
  943e9a39-c2dd-4425-9da0-8e58c11ba03e
  99399d7b-584f-417b-a98d-731b80be01dd
  9ea6ddd9-75fe-4613-8c58-49d90a701363
  0ee1d1cf-626c-404e-be19-81704a58108d
  11fc50b6-cc95-4505-b02d-45dbcb278c91
  1425a282-8464-41c1-b6a3-a1349c1a0dd3
  2581be92-0287-4897-a109-fc484128786a
  26e438a6-15fe-40b0-8d7e-bb25f89e284b
  2321fca0-4db4-4376-bb8c-0a2fe45c721f
  295ffe8a-8bfd-4c5b-a37d-91cb187f4ef1
  32ac2f7d-9dde-400f-aa0d-847a3d7f5ff8
  0ad4e2a8-8c7f-410b-9880-b70afe7bedc6
  33a40bd0-4e1a-4b62-9166-8b63c999c60a
  34e4f3ab-6ada-4ded-872a-65f06e9480d5
  3b17feb0-51ce-4c18-9dd3-45c0cc83192b
  3f913442-bd04-4482-b340-4fce3795588a
  3fee3bda-2ce5-492b-8605-905fb3da9d37
  40a4077b-bc2f-403b-920e-4825a79a95c7
  458ec90a-711f-4c5e-bdf1-f68c86e401c9
  46a7b828-aee0-41ad-b28e-c2a5aa1cfa62
  429b03d3-6649-4cfb-9227-3d88eb3a900c
  47de68e6-d2d2-4f58-b2b2-63b20e8d110f
  51c6eda7-6404-443b-9229-62275c99dd96
  504e05ae-2c28-49ed-9250-7477e3dd207c
  55a6a20e-ed8c-48f2-b94f-ab79bc15c07c
  54161825-8f73-4971-b166-c71e6178f1a6
  88b5c86c-0e6d-4a91-af6a-7b6db187c019
  591b88c7-78de-4161-8ab1-6c28b99b8874
  69cec6da-9d73-4183-91fc-5ccb5187ca64
  64caebf0-a80c-443e-8a78-5ffff3fcd9cd
  6b9d3b7c-2058-43a0-8b8f-5e55b446d320
  89d913b4-bf68-4495-b710-489767219163
  8b25656c-55a2-4162-8c17-7ae63111c378
  6f53ad08-c54e-4797-b84b-6519484e5d8b
  73de9c11-4778-4586-83e1-d3cf8a75b538
  7589d03a-c4e8-4e39-8932-44e0a154bdc0
  b21e3336-7931-4994-b8ec-cc884f50327a
  a4776ee8-c4f6-472f-a1c6-b35271063801
  c2000719-d524-4b04-8e0b-427ed482c6ed
  f32be2d3-801b-4e05-a19b-f60558583af0
  c081eab0-f6f2-483f-a4b1-70931cb1f73a
  94178931-101f-4cbb-82dc-bf46ee07459c
  e0be06c8-1e23-4c8d-8514-230c6a07e3ab
  cbad5a6e-6abd-46c8-bdf2-9befbfe5fd7d
  929862c7-098c-40ed-aeed-bd353fb124ef
  ac528f73-5163-4134-9225-53c1b2bb3c75
  c26948de-86c5-4943-818c-e71ff091a81f
  cde5515d-3c1d-4c6d-8dd3-6ab1f8c30107
  c434164b-ea53-4ed4-9c59-ff12a26c58de
  b5dd588b-7ceb-437b-99e1-85506ff14555
  af824c7b-4f59-4623-88e2-9d1e26cef490
  b1501c84-ea0a-4ebe-9e6d-5bd3026bb976
  c0514241-a20b-411e-860a-459dae2cc019
  ba29b2ae-83be-46f5-9069-6c2572ca19a0
  d0502e7d-eb1d-4aed-8f66-bce7e97ae8a7
  c8244512-44f3-4eed-8310-a9c433281487
  c40951f7-b729-433e-b7a8-e467a0ee66f2
  c761a274-028a-473b-b9cd-a858f6d1b2de
  d0816782-86ea-4c0c-8b0f-ddf5c32ed292
  e286c81a-1d8d-4c7c-8b95-e4f9d51f448b
  e2dfc607-ef04-44aa-bcde-abba7fb2ef17
  eaa1a761-1a0c-4859-97db-af74b0ac135f
  f1f71327-beee-4e68-9024-bcef2160c81a
  f236c33d-701e-46fb-ac66-a44493b3e0b6
  fd1a057e-d7d9-45d8-9fe1-1f572454b71d
  e6cc1529-4cbe-48e9-a271-fbfd570dfb59
  e5ef9aee-28f2-44ae-84dc-7ff83aa867ea
  929ef852-2a4a-4149-9d44-cfe9b1a9d565
  ba991aeb-21a5-478f-807b-6197134f2e26
  a3633494-ba7a-40f8-bcde-3e4b054ec180
  fb0315a8-2b67-4ee0-b8e3-8f2c0c46afc4
  28643beb-b054-471e-8a85-7c7c3158c935
  44dad020-bd08-4f4e-91e8-abbd60a9461a
  3a70e449-ef71-4fa0-a47d-3383220a051d
  1638caa9-bc3d-4a61-bfaf-e4813829e125
  7366e6f8-a007-4aa0-8261-7fdbb20dbb31
  f678d4cb-1adb-4a96-a044-e5fae51c4945
  e754d07d-696e-4fb8-8e0f-7df7949bf413
  28493edf-7db7-4024-80ea-710b766e60fe
  47f6cdf5-935b-42c3-9055-ccfc93eef831
  f401e983-ee22-492f-8805-a86dd2d08e60
  85ff1892-4e20-4f55-87f8-b633c8a3be4b
  f86bc9c2-8b47-48ec-87fd-c7e415c3fffb
].map do |content_id|
  raise "NOT DELETED" if StatisticsAnnouncement.find_by(content_id: content_id)

  StatisticsAnnouncement.unscoped.find_by(content_id: content_id)
end

deleted_statistics_announcements.each do |sa|
  sa.update_columns(
    redirect_url: "/government/statistics/announcements",
    updated_at: Time.zone.now,
  )
  Whitehall::PublishingApi.publish_redirect_async(sa.content_id, sa.reload.redirect_url)
rescue StandardError => e
  puts "Failed to update and publish redirect for #{sa.content_id}: #{e.message}"
end
