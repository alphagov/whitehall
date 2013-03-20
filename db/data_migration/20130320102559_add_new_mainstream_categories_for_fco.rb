[
  ['Help for British nationals living overseas', 'Guidance for UK citizens residing overseas and those agencies providing them with support services.', 'abroad/living-abroad', 'Living abroad'],
  ['Help for British nationals travelling overseas', 'Guidance for travellers and for agencies who provide support to UK citizens overseas.', 'abroad/travel-abroad', 'Travel abroad'],
  ['Education materials about overseas travel', 'Teaching and learning materials for schools and students on how to plan gap years, travel insurance and staying safe overseas.', 'abroad/travel-abroad', 'Travel abroad'],
].each do |row|
  title, description, parent_tag, parent_title = row
  unless category = MainstreamCategory.where(title: title).first
    category = MainstreamCategory.create(
      title: title,
      slug:  title.parameterize,
      parent_tag: parent_tag,
      parent_title: parent_title,
      description: description
      )
    if category
      puts "Mainstream category '#{category.title}' created"
    end
  else
    puts "Mainstream category '#{category.title}' already exists, skipping"
  end
end
