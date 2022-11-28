When(/^I (?:also )?filter by (only )?a keyword$/) do |only|
  fill_in_filter "Contains", "keyword", only.present?
end

When(/^I (?:also )?filter by (only )?a publication type$/) do |only|
  select_filter "Publication type", "Guidance", only.present?
end

When(/^I (?:also )?filter by (only )?a topic$/) do |only|
  select_filter "Topic", "A Topic", only.present?
end

When(/^I (?:also )?filter by (only )?a department$/) do |only|
  select_filter "Department", "A Department", only.present?
end

When(/^I (?:also )?filter by (only )?a world location$/) do |only|
  select_filter "World locations", "A World Location", only.present?
end

When(/^I (?:also )?filter by (only )?published date$/) do |only|
  clear_filters if only.present?
  fill_in "Published after", with: "01/01/2013"
  fill_in "Published before", with: "01/03/2013"
  click_on "Refresh results"
end
