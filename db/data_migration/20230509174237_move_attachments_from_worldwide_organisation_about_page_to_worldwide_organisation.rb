WorldwideOrganisation.all.each do |worldwide_organisation|
  puts "Processing #{worldwide_organisation.slug}"

  if worldwide_organisation.about_us.nil?
    puts "No published about page".indent(2)
    next
  end

  worldwide_organisation.about_us.attachments.each do |attachment|
    puts "Moving attachment ID: #{attachment.id}".indent(2)

    attachment.update!(attachable: worldwide_organisation)
  end

  worldwide_organisation.corporate_information_pages.where(corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id).each do |about_us|
    if !about_us.published? && about_us.attachments.any?
      puts "Non-published about page edition (ID: #{about_us.id}; state: #{about_us.state}) has attachments (IDs: #{about_us.attachments.map(&:id)}) that may be lost".indent(2)
      next
    end
  end
end
