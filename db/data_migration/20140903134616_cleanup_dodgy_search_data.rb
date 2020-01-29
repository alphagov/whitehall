scope = Publication.where(publication_type_id: PublicationType.statistical.map(&:id)).includes(:document)

scope.find_each do |statistics_publication|
  old_path = Whitehall.url_maker.publication_path(statistics_publication.document)

  puts "Removing #{old_path} from the search index and re-indexing as #{statistics_publication.search_link}"
  SearchIndexDeleteWorker.perform_async(old_path, :government)
  Whitehall::SearchIndex.add(statistics_publication)
end
