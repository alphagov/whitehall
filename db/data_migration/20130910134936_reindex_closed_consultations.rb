def closed_consultations
  Enumerator.new do |y|
    Consultation.published.closed_since(1.month.ago).find_each do |edition|
      y << edition.search_index
    end
  end
end
index = Whitehall::SearchIndex.for(:government)
index.add_batch(closed_consultations)
index.commit