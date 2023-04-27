WorldwideOrganisation.all.each do |worldwide_organisation|
  puts "Processing #{worldwide_organisation.slug}"

  if worldwide_organisation.about_us.nil?
    puts "No published about page".indent(2)
    next
  end

  if worldwide_organisation.about_us.translations.none?
    puts "No translations for published about page".indent(2)
    next
  end

  worldwide_organisation.about_us.translations.each do |source_translation|
    puts "Processing source translation for #{source_translation.locale}".indent(2)

    target_translation = worldwide_organisation.translations.find_by(locale: source_translation.locale)

    if target_translation.nil?
      puts "Creating target translation - name & services fields will be blank".indent(4)

      target_translation = worldwide_organisation.translations.create!(locale: source_translation.locale)
    else
      puts "Found existing translation".indent(4)
    end

    puts "Updating target translation for #{target_translation.locale}".indent(4)
    target_translation.update!(
      summary: source_translation.summary,
      body: source_translation.body,
    )
  end

  if worldwide_organisation.draft_about_us.present?
    puts "#{worldwide_organisation.name} has a draft about page - this data may be lost".indent(2)
    next
  end
end
