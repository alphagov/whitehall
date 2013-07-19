def remove_first_image_from_body(edition)
  new_body = edition.body.gsub(/^!!1[^\d]/, '')
  edition.update_column(:body, new_body)
end

NewsArticle.find_each { |article| remove_first_image_from_body(article) }
CaseStudy.find_each { |study| remove_first_image_from_body(study) }
