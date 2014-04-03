category_map = {
  'flooding-and-coastal-change' => ['environment-countryside/flooding-extreme-weather', 'Flooding and extreme weather'],
  'wildlife-and-habitat-conservation' => ['environment-countryside/wildlife-biodiversity', 'Wildlife and biodiversity']
}

category_map.each do |subcategory_slug, (new_parent_tag, new_parent_title)|
  if subcategory = MainstreamCategory.find_by_slug(subcategory_slug)
    subcategory.update_attributes(
      parent_tag: new_parent_tag,
      parent_title: new_parent_title
    )
  else
    raise "Missing MainstreamCategory #{subcategory_slug}"
  end
end
