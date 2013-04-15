[
  ['Helping people with the reformed workplace pension', 'Guidance and resources for pension providers and employers.', 'employing-people/pensions', 'Pensions for your staff'],
  ['Working with people claiming Universal Credit', 'Guidance and resources for benefits advisers and DWP partner organisations.', 'benefits/entitlement', 'Benefits entitlement']
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
