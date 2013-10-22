
When(/^I (?:also )?filter by (only )?a keyword$/) do |only|
  fill_in_filter "Contains", "keyword", !!only
end

When(/^I (?:also )?filter by (only )?a publication type$/) do |only|
  select_filter "Publication type", "Statistics", !!only
end

When(/^I (?:also )?filter by (only )?a topic$/) do |only|
  select_filter "Topic", "A Topic", !!only
end

When(/^I (?:also )?filter by (only )?a department$/) do |only|
  select_filter "Department", "A Department", !!only
end

When(/^I (?:also )?filter by (only )?a world location$/) do |only|
  select_filter "World locations", "A World Location", !!only
end

When(/^I (?:also )?filter by (only )?published date$/) do |only|
  if only
    clear_filters
  end
  page.fill_in "Published after", with: "01/01/2013"
  page.fill_in "Published before", with: "01/03/2013"
  page.click_on "Refresh results" unless page.driver.is_a? Capybara::Poltergeist::Driver
end

def select_filter(label, value, only)
  if only
    clear_filters
  end
  page.select value, from: label
  page.click_on "Refresh results" unless page.driver.is_a? Capybara::Poltergeist::Driver
end

def fill_in_filter(label, value, only)
  if only
    clear_filters
  end
  page.fill_in label, with: value
  page.click_on "Refresh results" unless page.driver.is_a? Capybara::Poltergeist::Driver
end

def clear_filters
  within '#document-filter' do
    page.fill_in "Contains", with: ""                             if page.has_content?("Contains")
    page.select "All publication types", from: "Publication type" if page.has_content?("Publication type")
    page.select "All topics", from: "Topic"                       if page.has_content?("Topic")
    page.select "All departments", from: "Department"             if page.has_content?("Department")
    page.select "All locations", from: "World locations"          if page.has_content?("World locations")
    page.fill_in "Published after", with: ""                      if page.has_content?("Published after")
    page.fill_in "Published before", with: ""                     if page.has_content?("Published before")
  end
end


### Policies

Given(/^I'm looking at the policies index showing several policies with various attributes$/) do
  topic = create(:topic, name: "A Topic")
  department = create(:ministerial_department, name: "A Department")

  create(:published_policy, title: "A policy with the topic", topics: [topic])
  create(:published_policy, title: "A policy with the department", organisations: [department])
  create(:published_policy, title: "A policy with both the topic and the department", topics: [topic], organisations:[department])
  create(:published_policy, title: "A keyword one", topics: [topic], organisations:[department])

  visit policies_path

  assert page.has_content? "A policy with the topic"
  assert page.has_content? "A policy with the department"
  assert page.has_content? "A policy with both the topic and the department"
  assert page.has_content? "A keyword one"

  assert page.has_content? "Showing 4 results about All topics by All organisations"
end

Then(/^I should only see policies for that topic$/) do
  assert page.has_content? "A policy with the topic"
  assert page.has_no_content? "A policy with the department"
  assert page.has_content? "A policy with both the topic and the department"
  assert page.has_content? "A keyword one"

  assert page.text.match /Showing 3 results about A Topic . by All organisations/
end

Then(/^I should only see policies for both the topic and the department$/) do
  assert page.has_no_content? "A policy with the topic"
  assert page.has_no_content? "A policy with the department"
  assert page.has_content? "A policy with both the topic and the department"
  assert page.has_content? "A keyword one"

  assert page.text.match /Showing 2 results about A Topic . by A Department ./
end

Then(/^I should only see policies for the topic, the department and the keyword$/) do
  assert page.has_no_content? "A policy with the topic"
  assert page.has_no_content? "A policy with the department"
  assert page.has_no_content? "A policy with both the topic and the department"
  assert page.has_content? "A keyword one"

  assert page.text.match /Showing 1 result about A Topic . by A Department . containing keyword ./
end


### Publications

Given(/^I'm looking at the publications index showing several publications with various attributes$/) do
  topic = create :topic, name: "A Topic"
  department = create(:ministerial_department, name: "A Department")
  world_location = create(:world_location, name: "A World Location")

  create :published_publication, title: "Publication with keyword"
  create :published_statistics, title: "Statistics publication"
  create :published_publication, title: "Publication with the topic", topics: [topic]
  create :published_publication, title: "Publication with the department and keyword", organisations: [department]
  create :published_publication, title: "Publication with the world location", world_locations: [world_location]
  create :published_publication, title: "Publication published too early", first_published_at: "2012-01-01"
  create :published_publication, title: "Publication published too late", first_published_at: "2013-06-01"
  create :published_publication, title: "Publication published within date range", first_published_at: "2013-02-01"

  visit publications_path

  assert page.has_content? "Publication with keyword"
  assert page.has_content? "Statistics publication"
  assert page.has_content? "Publication with the topic"
  assert page.has_content? "Publication with the department and keyword"
  assert page.has_content? "Publication with the world location"
  assert page.has_content? "Publication published too early"
  assert page.has_content? "Publication published too late"
  assert page.has_content? "Publication published within date range"
end

Then(/^I should only see publications for that keyword$/) do
  assert page.has_content? "Publication with keyword"
  assert page.has_no_content? "Statistics publication"
  assert page.has_no_content? "Publication with the topic"
  assert page.has_content? "Publication with the department and keyword"
  assert page.has_no_content? "Publication with the world location"
  assert page.has_no_content? "Publication published too early"
  assert page.has_no_content? "Publication published too late"
  assert page.has_no_content? "Publication published within date range"

  assert page.text.match /Showing 2 results about All topics by All organisations containing keyword ./
end

Then(/^I should only see publications for the keyword and department$/) do
  assert page.has_no_content? "Publication with keyword"
  assert page.has_no_content? "Statistics publication"
  assert page.has_no_content? "Publication with the topic"
  assert page.has_content? "Publication with the department and keyword"
  assert page.has_no_content? "Publication with the world location"
  assert page.has_no_content? "Publication published too early"
  assert page.has_no_content? "Publication published too late"
  assert page.has_no_content? "Publication published within date range"

  assert page.text.match /Showing 1 result about All topics by A Department . containing keyword ./
end

Then(/^I should only see the publications of that publication type$/) do
  assert page.has_no_content? "Publication with keyword"
  assert page.has_content? "Statistics publication"
  assert page.has_no_content? "Publication with the topic"
  assert page.has_no_content? "Publication with the department and keyword"
  assert page.has_no_content? "Publication with the world location"
  assert page.has_no_content? "Publication published too early"
  assert page.has_no_content? "Publication published too late"
  assert page.has_no_content? "Publication published within date range"

  assert page.text.match /Showing 1 result about All topics by All organisations/
end

Then(/^I should only see publications for that topic$/) do
  assert page.has_no_content? "Publication with keyword"
  assert page.has_no_content? "Statistics publication"
  assert page.has_content? "Publication with the topic"
  assert page.has_no_content? "Publication with the department and keyword"
  assert page.has_no_content? "Publication with the world location"
  assert page.has_no_content? "Publication published too early"
  assert page.has_no_content? "Publication published too late"
  assert page.has_no_content? "Publication published within date range"

  assert page.text.match /Showing 1 result about A Topic . by All organisations/
end

Then(/^I should only see publications for that department$/) do
  assert page.has_no_content? "Publication with keyword"
  assert page.has_no_content? "Statistics publication"
  assert page.has_no_content? "Publication with the topic"
  assert page.has_content? "Publication with the department and keyword"
  assert page.has_no_content? "Publication with the world location"
  assert page.has_no_content? "Publication published too early"
  assert page.has_no_content? "Publication published too late"
  assert page.has_no_content? "Publication published within date range"

  assert page.text.match /Showing 1 result about All topics by A Department ./
end

Then(/^I should only see publications for that world location$/) do
  assert page.has_no_content? "Publication with keyword"
  assert page.has_no_content? "Statistics publication"
  assert page.has_no_content? "Publication with the topic"
  assert page.has_no_content? "Publication with the department and keyword"
  assert page.has_content? "Publication with the world location"
  assert page.has_no_content? "Publication published too early"
  assert page.has_no_content? "Publication published too late"
  assert page.has_no_content? "Publication published within date range"

  assert page.text.match /Showing 1 result about All topics by All organisations from A World Location ./
end

Then(/^I should only see publications for the published date range$/) do
  assert page.has_no_content? "Publication with keyword"
  assert page.has_no_content? "Statistics publication"
  assert page.has_no_content? "Publication with the topic"
  assert page.has_no_content? "Publication with the department and keyword"
  assert page.has_no_content? "Publication with the world location"
  assert page.has_no_content? "Publication published too early"
  assert page.has_no_content? "Publication published too late"
  assert page.has_content? "Publication published within date range"

  assert page.text.match /Showing 1 result about All topics by All organisations published after 01\/01\/2013 published before 01\/03\/2013 ./
end


### Announcements
Given(/^I'm looking at the announcements index showing several announcements with various attributes$/) do
  topic = create :topic, name: "A Topic"
  department = create(:ministerial_department, name: "A Department")
  world_location = create(:world_location, name: "A World Location")

  create :published_news_story, title: "News Article with keyword, topic, department, world location published within date range",
         first_published_at: "2013-02-01",
         topics: [topic],
         organisations: [department],
         world_locations: [world_location]
  create :published_fatality_notice, title: "Fatality Notice with keyword, topic, department, world location published within date range",
         first_published_at: "2013-02-01",
         topics: [topic],
         organisations: [department],
         world_locations: [world_location]
  create :published_news_story, title: "News Article without wordkey",
         first_published_at: "2013-02-01",
         topics: [topic],
         organisations: [department],
         world_locations: [world_location]
  create :published_news_story, title: "News Article with keyword without topic",
         first_published_at: "2013-02-01",
         organisations: [department],
         world_locations: [world_location]
  create :published_news_story, title: "News Article with keyword without department",
         first_published_at: "2013-02-01",
         topics: [topic],
         world_locations: [world_location]
  create :published_news_story, title: "News Article with keyword without world location",
         first_published_at: "2013-02-01",
         topics: [topic],
         organisations: [department]
  create :published_news_story, title: "News Article with keyword published out of range",
         first_published_at: "2013-06-01",
         topics: [topic],
         organisations: [department],
         world_locations: [world_location]

  visit announcements_path

  assert page.has_content? "News Article with keyword, topic, department, world location published within date range"
  assert page.has_content? "Fatality Notice with keyword, topic, department, world location published within date range"
  assert page.has_content? "News Article without wordkey"
  assert page.has_content? "News Article with keyword without topic"
  assert page.has_content? "News Article with keyword without department"
  assert page.has_content? "News Article with keyword without world location"
  assert page.has_content? "News Article with keyword published out of range"

  assert page.text.match /Showing 7 results about All topics by All organisations/
end

When(/^I filter by a keyword, an announcement type, a topic, a department, a world location and published date$/) do
  clear_filters
  within '#document-filter' do
    page.fill_in "Contains", with: "keyword"
    page.select "News stories", from: "Announcement type"
    page.select "A Topic", from: "Topic"
    page.select "A Department", from: "Department"
    page.select "A World Location", from: "World locations"
    page.fill_in "Published after", with: "01/01/2013"
    page.fill_in "Published before", with: "01/03/2013"
  end
  page.click_on "Refresh results"
end

Then(/^I should only see announcements matching those filters$/) do
  assert page.has_content? "News Article with keyword, topic, department, world location published within date range"
  assert page.has_no_content? "Fatality Notice with keyword, topic, department, world location published within date range"
  assert page.has_no_content? "News Article without wordkey"
  assert page.has_no_content? "News Article with keyword without topic"
  assert page.has_no_content? "News Article with keyword without department"
  assert page.has_no_content? "News Article with keyword without world location"
  assert page.has_no_content? "News Article with keyword published out of range"

  assert page.text.match /Showing 1 result about A Topic . by A Department . from A World Location . containing keyword . published after 01\/01\/2013 published before 01\/03\/2013/
end

Given(/^I'm looking at the announcements index in french$/) do
  visit announcements_path + '.fr'
end

Then(/^I can only filter by world location \(or Pays in french\)$/) do
  within '#document-filter' do
    assert page.has_selector?('label', count: 1)
    assert page.has_content?("Pays")
  end
end
