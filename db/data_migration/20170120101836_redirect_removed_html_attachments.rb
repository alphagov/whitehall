# These content items are html attachments removed in a previous edition
# they are presented as children in the content store but the relationship
# no longer exists in the latest edition so redirect them to the parent publication
redirect_data = {
  "d4d7b18e-ff53-4405-be24-59027c0d7300" => "/government/publications/advice-funding-regulations-for-post-16-provision",
  "997384c8-a2b4-43c9-b84f-914e08854aba" => "/government/publications/fishing-vessel-licence-variations",
  "c0e4f8cb-c92d-4a06-ada9-2399216d91b0" => "/government/publications/fishing-vessel-licence-variations",
  "4d44f717-72a9-43f3-83ad-38ef38ca8a08" => "/government/publications/fishing-vessel-licence-variations",
  "48352489-39c5-4ad0-80d3-95f6949265f1" => "/government/publications/fishing-vessel-licence-variations",
  "063a9dc1-3621-470a-84c6-65a524c572b7" => "/government/publications/fishing-vessel-licence-variations",
  "0824f41a-56f0-42ad-91a1-793c75f72589" => "/government/publications/fishing-vessel-licence-variations",
  "b55c34cc-e23d-428b-b661-09da07b7622b" => "/government/publications/fishing-vessel-licence-variations",
  "d9ffccc6-5e73-4f82-adf4-443b6ff5d22d" => "/government/publications/fishing-vessel-licence-variations",
  "11c67e52-f80b-4822-ab42-c667890c064d" => "/government/publications/fishing-vessel-licence-variations",
  "1f754ebd-77b3-4297-9457-4f4332828671" => "/government/publications/fishing-vessel-licence-variations",
  "1416cbf7-e693-47ee-b81b-36996cd08011" => "/government/publications/fishing-vessel-licence-variations",
  "d6425bef-22d5-4853-91ba-7812d8f79003" => "/government/publications/fishing-vessel-licence-variations",
  "88f6a9de-cffb-44b9-a23f-afe0d07eb28f" => "/government/publications/fishing-vessel-licence-variations",
  "bc5582e9-4014-41e2-aeec-4a585a104ffd" => "/government/publications/fishing-vessel-licence-variations",
  "bfebe351-0dc8-4aa1-9b99-63c9d8dfb25b" => "/government/publications/fishing-vessel-licence-variations",
  "04840e72-a3aa-4054-b5d9-c78f405ed5bd" => "/government/publications/fishing-vessel-licence-variations",
  "9ff879c3-e013-4d72-910d-64ec9f841053" => "/government/publications/fishing-vessel-licence-variations",
  "fca4b81c-e226-4308-a9fd-22aa4bff57d3" => "/government/publications/fishing-vessel-licence-variations",
  "59c12cca-6a0e-4957-bed0-bafe7ab96f0a" => "/government/publications/fishing-vessel-licence-variations",
  "de81f372-7627-4df0-9019-1471f2c14c95" => "/government/publications/fishing-vessel-licence-variations",
  "21073672-6e3a-4e81-8672-33915f5a05a6" => "/government/publications/fishing-vessel-licence-variations",
  "94fd8120-e5f5-4e2d-bf89-e36812c264c1" => "/government/publications/fishing-vessel-licence-variations",
  "a089dd24-8fad-475d-8555-51007a39f7ad" => "/government/publications/current-catch-limits-10-metres-and-under-pool",
  "cbf561fd-6f50-4ede-a342-fbec81324b03" => "/government/publications/current-catch-limits-over-10-metre-non-sector-pool",
  "cb837f2a-26f7-4be3-9b7e-ad474644b9d4" => "/government/publications/homes-and-communities-agency-register-of-interests",
  "3ba7add2-3f3b-4da0-9eb2-9a503326dbb0" => "/government/publications/teacher-recruitment-bulletin",
  "432dc392-6229-475d-8137-bd6cfb0cf2b3" => "/government/publications/teacher-recruitment-bulletin",
  "ea3f8c88-3138-4fb5-8e20-ac52833018ac" => "/government/publications/sustainable-mod-annual-report-2015-to-2016",
  "ff59f9b2-ace3-4567-844c-a75e23c76251" => "/government/publications/cac-outcome-unite-the-union-teknomek-limited--2",
}

redirect_data.each do |content_id, redirect_url|
  PublishingApiRedirectWorker.perform_async(content_id, redirect_url, :en, false)
end
