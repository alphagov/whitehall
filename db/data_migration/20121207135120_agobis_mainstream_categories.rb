require 'csv'

data = CSV.read(__FILE__.gsub(/\.rb/, '.csv'), headers: true, encoding: "UTF-8")

data.each do |row|
  title = row['Inside Gov detailed guidance category']
  parent_tag = row['Mainstream browse full slug']
  parent_title = row['Mainstream browse sub category']
  description = row['Inside Gov detailed guidance category summary']
  category = MainstreamCategory.create(
    title: title,
    slug:  title.parameterize,
    parent_tag: parent_tag,
    parent_title: parent_title,
    description: description
  )
  if category
    puts "Mainstream category #{category.title} created"
  end
end
