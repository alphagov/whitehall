[
  ['Emergencies: preparation, response and recovery', 'Guidance for responder agencies and other authorities that must plan for and respond to emergencies in the UK.', 'citizenship/government', 'Living in the UK, government and democracy'],
  ['Devolution: how it affects policies and services', 'Advice for public servants and other agencies about devolved responsibilities and accountability.', 'citizenship/government', 'Living in the UK, government and democracy']
].each do |row|
  title, description, parent_tag, parent_title = row
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
end
