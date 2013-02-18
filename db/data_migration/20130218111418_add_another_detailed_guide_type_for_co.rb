[
  ['Legislative process: taking a bill through Parliament', 'If you are working on proposed legislation or on regulations or orders that may become statutory, check the process by which bills become law.', 'citizenship/government', 'Living in the UK, government and democracy']
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

