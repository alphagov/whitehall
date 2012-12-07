category = MainstreamCategory.where(title: "Trades union administration and membership").first

if category
  title = "Trade union administration and membership"
  category.title = title
  category.slug = title.parameterize
  category.save
  puts "Updated #{category.title}"
end
