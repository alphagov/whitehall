fixes = {
  'arms-embargo-on-armenia-and-azerbaijan' => 'arms-embargo-on-armenia',
  'new-homes-bonus-grant-determination-2012-to-2013' =>
    'new-homes-bonus-grant-determination',
  'bis-digital-stategy' =>
    'bis-digital-strategy',
  'uk-h2mmobility-potential-for-hydrogen-fuel-cell-electric-vehicles-phase-1-results' =>
    'uk-h2mobility-potential-for-hydrogen-fuel-cell-electric-vehicles-phase-1-results',
  'service-personnel-and-veterans-agency-spva-annual-report-and-accounts-2009-and-2010-wrong-url-seems-to-have-been-included' =>
    'service-personnel-and-veterans-agency-spva-annual-report-and-accounts-2009-and-2010'
}

puts "Replacing #{fixes.size} slugs"
fixes.each.with_index do |(old_slug, new_slug), i|
  d = Document.find_by_slug(old_slug)
  if d
    puts "#{i}: Found #{d.id}: #{d.latest_edition.title}"
    puts "    #{old_slug} => #{new_slug}"
    d.slug = new_slug
    d.save
  else
    puts "#{i}: Not found: #{old_slug}"
    if Document.find_by_slug(new_slug)
      puts "    New slug '#{new_slug}' already present"
    end
  end
end
