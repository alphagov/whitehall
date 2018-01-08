require "csv"

PUBLISHED_AND_PUBLISHABLE_STATES = %w(published draft archived submitted rejected scheduled).freeze

csv_file = File.join(File.dirname(__FILE__), "20150505155406_batch_update_policital_status.csv")
csv = CSV.parse(File.open(csv_file), headers: true)

csv.each do |row|
  puts "#{row["type"]},#{row["slug"]}"
  document = Document.find_by(document_type: row["type"].camelize, slug: row["slug"])
  unless document
    puts "!! no document found"
    next
  end
  editions = document.editions.where(state: PUBLISHED_AND_PUBLISHABLE_STATES)
  unless editions
    puts "!! no editions found"
    next
  end

  puts "\tsetting political status to: #{row["political"]}"
  editions.each { |edition|
    edition.update_column(:political, row["political"] == "true")
  }

  if row["publication-type"]
    new_type = PublicationType.find_by_slug(row["publication-type"].parameterize)
    unless new_type
      puts "!! publication type not found: #{row["publication-type"]}"
      next
    end

    puts "\tsetting publication type to: #{new_type.singular_name}"
    editions.each { |edition|
      edition.update_column(:publication_type_id, new_type.id)
    }
  end
end
