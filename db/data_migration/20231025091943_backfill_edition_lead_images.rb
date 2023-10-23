puts "Backfilling lead_image_id for case studies"

CaseStudy.joins(:images).distinct.find_each(batch_size: 100, &:update_lead_image)

puts "Backfilling lead_image_id for news articles"

NewsArticle.joins(:images).distinct.find_each(batch_size: 100, &:update_lead_image)
