index = Whitehall::SearchIndex.for(:government)
index.add_batch(Consultation.published.search_index)
index.commit
