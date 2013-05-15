When /^I create a new topical event "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create_topical_event(name: name, description: description)
end

When /^I create a new topical event "([^"]*)" with description "([^"]*)" and it ends today$/ do |name, description|
  create_topical_event(name: name, description: description, start_date: 2.months.ago.to_date.to_s, end_date: Date.today.to_s)
end

Then /^I should not see the topical event "([^"]*)" on the topics listing$/ do |topical_event_name|
  topical_event = TopicalEvent.find_by_name!(topical_event_name)
  visit topics_path
  refute page.has_css?(record_css_selector(topical_event))
end

Then /^I should see the topical event "([^"]*)" on the frontend is archived$/ do |topical_event_name|
  topical_event = TopicalEvent.find_by_name!(topical_event_name)
  visit topical_event_path(topical_event)
  assert page.has_css?(".archived", text: "Archived")
end

Then /^I should see the topical event "([^"]*)" in the admin interface$/ do |topical_event_name|
  topical_event = TopicalEvent.find_by_name!(topical_event_name)
  visit admin_topical_events_path(topical_event)
  assert page.has_css?(record_css_selector(topical_event))
end

Then /^I should see the topical event "([^"]*)" on the frontend$/ do |topical_event_name|
  topical_event = TopicalEvent.find_by_name!(topical_event_name)
  visit topical_event_path(topical_event)
  assert page.has_css?(record_css_selector(topical_event))
end

When /^I draft a new speech "([^"]*)" relating it to topical event "([^"]*)"$/ do |speech_name, topical_event_name|
  begin_drafting_speech title: speech_name
  select topical_event_name, from: "Topical events"
  click_button "Save"
end

When /^I draft a new news article "([^"]*)" relating it to topical event "([^"]*)"$/ do |news_article_title, topical_event_name|
  begin_drafting_news_article title: news_article_title
  select topical_event_name, from: "Topical events"
  click_button "Save"
end

When /^I draft a new publication "([^"]*)" relating it to topical event "([^"]*)"$/ do |publication_title, topical_event_name|
  begin_drafting_publication publication_title
  select topical_event_name, from: "Topical events"
  click_button "Save"
end

When /^I draft a new consultation "([^"]*)" relating it to topical event "([^"]*)"$/ do |consultation_title, topical_event_name|
  begin_drafting_consultation title: consultation_title
  select topical_event_name, from: "Topical events"
  click_button "Save"
end

Then /^I should see (#{THE_DOCUMENT}) in the (announcements|publications|consultations) section of the topical event "([^"]*)"$/ do |edition, section, topical_event_name|
  topical_event = TopicalEvent.find_by_name!(topical_event_name)
  visit topical_event_path(topical_event)
  within "##{section}" do
    assert page.has_css?(record_css_selector(edition))
  end
end

When /^I feature the news article "([^"]*)" for topical event "([^"]*)" with image "([^"]*)"$/ do |news_article_title, topical_event_name, image_filename|
  topical_event = TopicalEvent.find_by_name!(topical_event_name)
  visit admin_topical_event_classification_featurings_path(topical_event)
  news_article = NewsArticle.find_by_title(news_article_title)
  within record_css_selector(news_article) do
    click_link "Feature"
  end
  attach_file "Select an image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :alt_text, with: "An accessible description of the image"
  click_button "Save"
end

Then /^I should see the featured news articles in the "([^"]*)" topical event are:$/ do |name, expected_table|
  visit topical_event_path(TopicalEvent.find_by_name!(name))
  rows = find('.featured-news').all('.news_article')
  table = rows.collect do |row|
    [
      row.find('h2').text.strip,
      File.basename(row.find('.featured-image')['src'])
    ]
  end
  expected_table.diff!(table)
end

def create_topical_event(options = {})
  visit admin_root_path
  click_link "Topical events"
  click_link "Create topical event"
  fill_in "Name", with: options[:name] || "topic-name"
  fill_in "Description", with: options[:description] || "topic-description"
  select_date "Start Date", with: options[:start_date] || 1.day.ago.to_s
  select_date "End Date", with: options[:end_date] || 1.month.from_now.to_s
  click_button "Save"
end