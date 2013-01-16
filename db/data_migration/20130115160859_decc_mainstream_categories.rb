require 'csv'

CSV.read(__FILE__.gsub(/\.rb/, '.csv'), headers: true, encoding: "UTF-8").each do |row|
  attributes = row.to_hash
  attributes["slug"] = attributes["title"].downcase.gsub(/\s+/, "-")
  category = MainstreamCategory.new(attributes)
  category.save!
  puts "Added category #{category.title}"
end
