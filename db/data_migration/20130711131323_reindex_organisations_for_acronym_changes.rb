index = Whitehall::SearchIndex.for(:government)
index.add_batch(Organisation.search_index)
index.commit
