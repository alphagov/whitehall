HtmlVersion.where(slug: nil).each do |html_version|
  def html_version.should_generate_new_friendly_id?
    true
  end

  html_version.save!
  puts "Edition #{html_version.edition.id}: Updating HTML version slug to '#{html_version.slug}'"
end
