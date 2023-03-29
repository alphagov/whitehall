require "csv"

csv_file = File.join(File.dirname(__FILE__), "20230327100626_reslug_dit_to_dbt.csv")
csv = CSV.parse(File.open(csv_file), headers: true)

csv.each do |row|
  puts "reslugging #{row['old_slug']}"

  old_slug = (row["old_slug"]).split("/").last
  new_slug = (row["new_slug"]).split("/").last

  if old_slug.include?("about") || old_slug.include?(".")
    puts "corporate information pages and translations are reslugged via their parent organisation and default locale"
    next
  end

  organisation = WorldwideOrganisation.find_by(slug: old_slug)

  unless organisation
    puts "!! no organisation found for: #{old_slug}"
    next
  end

  DataHygiene::OrganisationReslugger.new(organisation, new_slug).run!
  next
end
