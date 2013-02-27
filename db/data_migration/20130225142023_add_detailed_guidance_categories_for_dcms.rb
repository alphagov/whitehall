[
  ['Development of the arts, sport and heritage for local communities', 'Guidance and relevant data for local authorities, private investors and grant-making bodies.', 'housing/local-councils', 'Local councils and services'],
  ['Understanding and asserting your statutory rights', 'Duties of government and local authorities to uphold equality and provide services to citizens.', 'citizenship/government', 'Living in the UK, government and democracy']
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
