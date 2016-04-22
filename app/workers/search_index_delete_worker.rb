class SearchIndexDeleteWorker < WorkerBase

  attr_reader :link, :index

  def call(link, index)
    Whitehall::SearchIndex.for(index.to_sym).delete(link)
  end
end
