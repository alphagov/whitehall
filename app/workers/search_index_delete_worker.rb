class SearchIndexDeleteWorker < WorkerBase
  attr_reader :link, :index

  def perform(link, index)
    Whitehall::SearchIndex.for(index.to_sym, logger: logger).delete(link)
  end
end
