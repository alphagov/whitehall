PolicyGroup.all.each do |group|
  SearchIndexDeleteWorker.perform_async("/government/policy-advisory-groups/#{group.slug}", :government)
  SearchIndexDeleteWorker.perform_async("/government/policy-teams/#{group.slug}", :government)
  group.update_in_search_index
end
