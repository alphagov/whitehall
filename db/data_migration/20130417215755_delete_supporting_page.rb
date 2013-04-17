policy = Policy.published_as('providing-versatile-agile-and-battle-winning-armed-forces-and-a-smaller-more-professional-ministry-of-defence')

if policy
  page = SupportingPage.find_by_slug_and_edition_id('the-armed-forces-covenant', policy)
  if page
    page.destroy
    puts "#{page.title} deleted"
  else
    puts "Page doesn't exist"
  end
end
