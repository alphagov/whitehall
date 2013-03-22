edition_types_to_remove = [WorldwidePriority]
if ! Whitehall.world_feature?
  edition_types_to_remove << WorldLocationNewsArticle
end

edition_types_to_remove.each do |klass|
  klass.all.each do |edition|
    next unless edition.latest_edition
    edition.remove_from_search_index
    puts "#{edition.title} removed from Rummager"
  end
end
