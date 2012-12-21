When /^I create a new topical event "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create_topical_event(name: name, description: description)
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
  begin_drafting_document type: "news_article", title: news_article_title
  select topical_event_name, from: "Topical events"
  click_button "Save"
end

Then /^I should see (#{THE_DOCUMENT}) in the announcements section of the topical event "([^"]*)"$/ do |edition, topical_event_name|
  topical_event = TopicalEvent.find_by_name!(topical_event_name)
  visit topical_event_path(topical_event)
  within "#announcements" do
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
  click_button "Save"
end