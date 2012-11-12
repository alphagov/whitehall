require "csv"

csv = CSV.read("db/data_migration/20121112113303_new_detailed_categories.csv", headers: true)
csv.each do |row|
  attributes = row.to_hash
  attributes["slug"] = attributes["title"].downcase.gsub(/\s+/, "-")
  category = MainstreamCategory.new(attributes)
  category.save!
end
