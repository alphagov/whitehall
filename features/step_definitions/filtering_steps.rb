
When(/^I (?:also )?filter by (only )?a keyword$/) do |only|
  fill_in_filter "Contains", "keyword", !!only
end

When(/^I (?:also )?filter by (only )?a publication type$/) do |only|
  select_filter "Publication type", "Guidance", !!only
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
  page.click_on "Refresh results"
end

### Publications

Given(/^there are some published publications$/) do
  topic = create :topic, name: "A Topic"
  department = create(:ministerial_department, name: "A Department")
  world_location = create(:world_location, name: "A World Location")

  create :published_publication, title: "Publication with keyword"
  create :published_guidance, title: "Guidance publication"
  create :published_publication, title: "Publication with the topic", topics: [topic]
  create :published_publication, title: "Publication with the department and keyword", organisations: [department]
  create :published_publication, :with_command_paper, title: "Publication which is a command paper"
  create :published_publication, :with_act_paper, title: "Publication which is an act paper"
  create :published_publication, title: "Publication with the world location", world_locations: [world_location]
  create :published_publication, title: "Publication published too early", first_published_at: "2012-01-01"
  create :published_publication, title: "Publication published too late", first_published_at: "2013-06-01"
  create :published_publication, title: "Publication published within date range", first_published_at: "2013-02-01"
end

Then(/^I should be able to filter publications by keyword, publication type, topic, department, official document status, world location, and publication date$/) do
  fill_in_filter "Contains", "keyword"

  assert_listed_document_count 2
  assert page.has_content? "Publication with keyword"
  assert page.has_content? "Publication with the department and keyword"
  assert page.text.match /2 publications containing keyword ./

  select_filter "Department", "A Department"
  assert_listed_document_count 1
  assert page.has_content? "Publication with the department and keyword"
  assert page.text.match /1 publication by A Department . containing keyword ./

  select_filter "Publication type", "Guidance", and_clear_others: true
  assert_listed_document_count 1
  assert page.has_content? "Guidance publication"

  select_filter "Policy area", "A Topic", and_clear_others: true
  assert_listed_document_count 1
  assert page.has_content? "Publication with the topic"
  assert page.text.match /1 publication about A Topic ./

  select_filter "Department", "A Department", and_clear_others: true
  assert_listed_document_count 1
  assert page.has_content? "Publication with the department and keyword"
  assert page.text.match /1 publication by A Department ./

  select_filter "Official document status", "Command papers only", and_clear_others: true
  assert_listed_document_count 1
  assert page.has_content? "Publication which is a command paper"
  assert page.text.match /1 publication which are Command papers ./

  select_filter "Official document status", "Act papers only", and_clear_others: true
  assert_listed_document_count 1
  assert page.has_content? "Publication which is an act paper"
  assert page.text.match /1 publication which are Act papers ./

  select_filter "Official document status", "Command or act papers", and_clear_others: true
  assert_listed_document_count 2
  assert page.has_content? "Publication which is a command paper"
  assert page.has_content? "Publication which is an act paper"
  assert page.text.match /2 publications which are Command or Act papers ./

  select_filter "World locations", "A World Location", and_clear_others: true
  assert_listed_document_count 1
  assert page.has_content? "Publication with the world location"
  assert page.text.match /1 publication from A World Location ./

  clear_filters
  page.fill_in "Published after", with: "01/01/2013"
  page.fill_in "Published before", with: "01/03/2013"
  page.click_on "Refresh results"

  assert_listed_document_count 1
  assert page.has_content? "Publication published within date range"
  assert page.text.match /1 publication published after 01\/01\/2013 published before 01\/03\/2013 ./
end

When(/^I select a filter option without clicking any button$/) do
  page.select "A Department", from: "Department"
end

When(/^I select the (.*) publication type option without clicking any button$/) do |publication_type|
  page.select publication_type, from: "Publication type"
end

Then /^I should be notified that statistics have moved$/ do
  assert page.has_content?("Statistics publications have moved")
end

Then(/^the filtered publications refresh automatically$/) do
  assert_listed_document_count 1
  assert page.has_content? "Publication with the department and keyword"
  assert page.text.match /1 ?publication by A Department ./
end

### Announcements

Given(/^there are some published announcements$/) do
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
end

When(/^I visit the announcements index page$/) do
  visit announcements_path
end

Then(/^I should be able to filter announcements by keyword, announcement type, topic, department, world location and publication date$/) do
  clear_filters
  within '#document-filter' do
    page.fill_in "Contains", with: "keyword"
    page.select "News stories", from: "Announcement type"
    page.select "A Topic", from: "Policy area"
    page.select "A Department", from: "Department"
    page.select "A World Location", from: "World locations"
    page.fill_in "Published after", with: "01/01/2013"
    page.fill_in "Published before", with: "01/03/2013"
  end
  page.click_on "Refresh results"

  assert_listed_document_count 1
  assert page.has_content? "News Article with keyword, topic, department, world location published within date range"
  assert page.text.match /1 announcement about A Topic . by A Department . from A World Location . containing keyword . published after 01\/01\/2013 published before 01\/03\/2013/
end

Given(/^there are some published announcments including a few in French$/) do
  create :published_news_story, title: "News Article in English only"
  I18n.with_locale :fr do
    create :published_news_story, :translated, title: "C'est la vie"
  end
end

When(/^I visit the announcments index in French$/) do
  visit announcements_path + '.fr'
end

Then(/^I should see only announcements which have French translations$/) do
  assert page.has_content? "C'est la vie"
  assert page.has_no_content? "News Article in English only"
end

Then(/^I should be able to filter them by country \(or 'Pays' in French\)$/) do
  within '#document-filter' do
    assert page.has_selector?('label', count: 1)
    assert page.has_content?("Pays")
  end
end
