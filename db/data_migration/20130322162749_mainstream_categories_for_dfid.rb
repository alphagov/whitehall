require 'csv'

CSV.read(Rails.root.join('db/data_migration/20130322162749_mainstream_categories_for_dfid.csv')).each do |row|
  category = MainstreamCategory.create!( Hash[ [:parent_title, :parent_tag, :slug, :title, :description].zip(row)] )
  puts "Added new MainstreamCategory: '#{category.title}'"
end
