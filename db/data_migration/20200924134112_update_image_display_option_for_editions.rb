case_studies_with_images = Edition.find_by_sql(["SELECT e.* FROM editions e LEFT OUTER JOIN images ON e.id = images.edition_id WHERE type in ('CaseStudy') AND images.id IS NOT NULL"])

case_studies_with_images.each do |case_study|
  case_study.update_columns(image_display_option: "custom_image")
end

case_studies_without_images = Edition.find_by_sql(["SELECT e.* FROM editions e LEFT OUTER JOIN images ON e.id = images.edition_id WHERE type in ('CaseStudy') AND images.id IS NULL"])

case_studies_without_images.each do |case_study|
  case_study.update_columns(image_display_option: "organisation_image")
end
