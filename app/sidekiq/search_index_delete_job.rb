class SearchIndexDeleteJob < JobBase
  attr_reader :link, :index

  def perform(link, index)
    Whitehall::SearchIndex.for(index.to_sym, logger:).delete(link)
  end
end
