["England", "Scotland", "Wales", "Northern Ireland"].each do |nation_name|
  Nation.find_or_create_by_name(nation_name)
end