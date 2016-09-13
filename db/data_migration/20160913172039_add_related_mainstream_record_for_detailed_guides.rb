RelatedMainstream.destroy_all

guides = DetailedGuide.where([
           "related_mainstream_content_url IS NOT NULL
              AND related_mainstream_content_url != ''
              AND state != 'superseded'"
         ])
related_mainstream_not_found = []
n = 0
guides.each do |guide|
  guide.send(:fetch_related_mainstream_content_ids)
  if guide.content_ids[0].nil?
    related_mainstream_not_found << guide.id
  else
    n+=1
  end
  guide.send(:persist_content_ids)
  p "#{n}/#{guides.count}"
  p guide.related_mainstream
end

p "---"
p "Additional related mainstream content"
p "---"

additional_guides = DetailedGuide.where([
           "additional_related_mainstream_content_url IS NOT NULL
              AND additional_related_mainstream_content_url != ''
              AND state != 'superseded'"
         ])
additional_related_mainstream_not_found = []
n = 0
additional_guides.each do |guide|
  guide.send(:fetch_related_mainstream_content_ids)
  if guide.content_ids[0].nil?
    additional_related_mainstream_not_found << guide.id
  else
    n+=1
  end
  guide.send(:persist_content_ids)
  p "#{n}/#{additional_guides.count}"
  p guide.related_mainstream
end

p "Related mainstream found: #{n}/#{guides.count}"
p "Additional related mainstream found: #{n}/#{additional_guides.count}"
p "---"
p "Guides where related mainstream was not found: #{related_mainstream_not_found}"
p "Guides where additional related mainstream was not found: #{additional_related_mainstream_not_found}"
p "---"
p "Related mainstream urls not found"
related_mainstream_not_found.each { |id| p DetailedGuide.find(id).related_mainstream_content_url }
p "---"
p "Additional related mainstream urls not found"
additional_related_mainstream_not_found.each { |id| p DetailedGuide.find(id).additional_related_mainstream_content_url }
