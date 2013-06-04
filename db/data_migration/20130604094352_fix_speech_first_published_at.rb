speeches = Speech.published.where(first_published_at: nil)
speeches.each do |s|
  s.update_column(:first_published_at, s.delivered_on)
end
puts "#{speeches.count} speeches updated"