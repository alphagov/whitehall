categories = [
  {
    title: "Gun and weapon controls in Northern Ireland",
    description: "Administration of firearm licensing and authorisation for prohibited weapons in Northern Ireland.",
    parent_tag: "justice/rights",
    parent_title: "Your rights and the law"
  },
  {
    title: "Visiting publicly owned buildings",
    description: "Government buildings that are part of Britain's heritage: opening dates and times.",
    parent_tag: "citizenship/government",
    parent_title: "Living in the UK, government and democracy"
  },
]

categories.each do |category_data|
  category_data[:slug] = category_data[:title].parameterize
  unless category = MainstreamCategory.where(slug: category_data[:slug]).first
    category = MainstreamCategory.create(category_data)
    if category
      puts "Mainstream category '#{category.title}' created"
    end
  else
    puts "Mainstream category '#{category.title}' already exists"
  end
end
