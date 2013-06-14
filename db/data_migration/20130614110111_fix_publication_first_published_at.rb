pubs = Publication.published.where(first_published_at: nil)
pubs.each do |pub|
  time_stamp = pub.publication_date
  pub.update_column(:first_published_at, time_stamp)
end
puts "#{pubs.count} Publications updated"
puts "#{Publication.published.where(first_published_at: nil).count} still have no first_published_at"