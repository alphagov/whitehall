HtmlVersion.where(slug: '').each do |html_version|
  class << html_version
    def should_generate_new_friendly_id?
      true
    end
  end

  if (html_version.title.blank?)
    html_version.title = html_version.edition.title if html_version.title.blank?
    puts "Edition #{html_version.edition.id}: Updating HTML version title to '#{html_version.title}'"
  end
  html_version.save!
  puts "Edition #{html_version.edition.id}: Updating HTML version slug to '#{html_version.slug}'"
end
