def sector_tags_for_guide(guide)
  guide.mainstream_categories.select {|category|
    category.parent_tag == "oil-and-gas"
  }.map {|category|
    category.slug.sub(/\Aindustry-sector-oil-and-gas-/, 'oil-and-gas/')
  }
end

mainstream_categories = MainstreamCategory.where(parent_tag: 'oil-and-gas')
detailed_guides = mainstream_categories.map(&:detailed_guides).flatten.uniq

detailed_guides.each do |guide|
  guide.specialist_sector_tags = sector_tags_for_guide(guide)
end

mainstream_categories.delete_all