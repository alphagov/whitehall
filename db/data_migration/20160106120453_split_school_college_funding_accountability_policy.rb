# To remove: School and college funding and accountability - content_id: "5e11d7d1-7631-11e4-a3cb-005056011aef"
# To add:
# - #1 School and college accountability - content_id: "453affe4-5ebb-4f44-9f0a-44cfd32dc934"
# - #2 School and college funding - content_id: "17e4ab26-ee1f-4383-a345-d165c0b75fbf"
require "csv"

csv_file = File.join(File.dirname(__FILE__), "20160106120453_split_school_college_funding_accountability_policy.csv")

csv = CSV.parse(File.open(csv_file), headers: true)

csv.each do |row|
  slug = row["slug"]

  policies_to_remove = row["policies_to_remove"] ? row["policies_to_remove"].split(" ") : []
  policies_to_add = row["policies_to_add"] ? row["policies_to_add"].split(" ") : []

  document = Document.where(slug: slug).first

  unless document
    puts "Document does not exist, slug: #{slug}"
    next
  end

  puts "Processing: #{document.slug}"

  [
    document.published_edition,
    document.scheduled_edition,
    document.editions.where(state: "draft").last
  ].compact.each do |edition|
    policies_to_remove.each do |id|
      edition.delete_policy(id)
      puts "Policy removed: #{id}"
    end

    policies_to_add.each do |id|
      edition.add_policy(id)
      puts "Policy added: #{id}"
    end
  end
end
