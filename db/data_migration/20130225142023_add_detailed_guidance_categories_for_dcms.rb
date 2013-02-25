[
  ['Development of the arts, sport and heritage for local communities', 'Guidance and relevant data for local authorities, private investors and grant-making bodies.', 'housing/safety-environment', 'Safety and the environment in your community'],
  ['Understanding and asserting your statutory rights', 'Duties of government and local authorities to uphold equality and provide services to citizens.', 'citizenship/government', 'Living in the UK, government and democracy']
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
