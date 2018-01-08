RelatedMainstream.delete_all

guides = DetailedGuide.where([
           "related_mainstream_content_url IS NOT NULL
              AND (
                related_mainstream_content_url != ''
                OR
                additional_related_mainstream_content_url != ''
              )
              AND state != 'superseded'"
         ])
related_mainstream_not_found = []
additional_related_mainstream_not_found = []

guides_count = guides.count
guides.find_each.with_index do |guide, i|
  puts "#{i + 1}/#{guides_count}"
  guide.valid?

  if guide.errors[:related_mainstream_content_url].any? || guide.errors[:additional_related_mainstream_content_url].any?
    related_mainstream_not_found << guide.id
  end

  if guide.errors[:additional_related_mainstream_content_url].any?
    additional_related_mainstream_not_found << guide.id
  end

  guide.persist_content_ids
end

puts "---"
puts "Guides where related mainstream was not found:"
puts "#{related_mainstream_not_found.join(',')}"
puts "Guides where additional related mainstream was not found:"
puts "#{additional_related_mainstream_not_found.join(',')}"
puts "---"
puts "Related mainstream urls not found"
DetailedGuide.where(id: related_mainstream_not_found).pluck(:related_mainstream_content_url).each do |url|
  puts url
end
puts "---"
puts "Additional related mainstream urls not found"
DetailedGuide.where(id: additional_related_mainstream_not_found).pluck(:additional_related_mainstream_content_url).each do |url|
  puts url
end
