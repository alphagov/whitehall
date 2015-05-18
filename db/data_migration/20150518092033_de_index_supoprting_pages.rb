puts 'Removing publicly visible supporting pages from search'
SupportingPage.publicly_visible.with_translations(I18n.locale).find_each do |supporting_page|
  puts "'#{supporting_page.title}' (#{supporting_page.id})"
  supporting_page.remove_from_search_index
end
