Given(/^there is a topic with published documents$/) do
  @topic = create(:topic, name: "A Topic")
  department = create(:ministerial_department, name: "A Department")

  create(:published_publication, title: "Publication #1", topics: [@topic])
  create(:published_publication, title: "Publication #2", topics: [@topic], organisations: [department])
  create(:published_news_article, title: "News #1", topics: [@topic])

  @news = create(:published_news_article, title: "News #2", topics: [@topic])
end

When(/^I view featured documents for that topic$/) do
  visit admin_topic_classification_featurings_url(@topic)
  click_on "Reset all fields"
end

When(/^I filter by title$/) do
  fill_in "Title or slug", with: "publication"
  click_on "Search"
end

When(/^I filter by author$/) do
  select @news.authors.first.name, from: "Author"
  click_on "Search"
end

When(/^I filter by organisation$/) do
  select "A Department", from: "organisation"
  click_on "Search"
end

When(/^I filter by document type$/) do
  select "News articles", from: "Document type"
  click_on "Search"
end

Then(/^I see documents with that title$/) do
  assert_text "Publication #1"
  assert_text "Publication #2"

  assert_no_text "News #1"
  assert_no_text "News #2"
end

Then(/^I see documents by that author$/) do
  assert_text "News #2"

  assert_no_text "Publication #1"
  assert_no_text "Publication #2"
  assert_no_text "News #1"
end

Then(/^I see documents with that organisation$/) do
  assert_text "Publication #2"

  assert_no_text "Publication #1"
  assert_no_text "News #1"
  assert_no_text "News #2"
end

Then(/^I see documents with that document type$/) do
  assert_text "News #1"
  assert_text "News #2"

  assert_no_text "Publication #1"
  assert_no_text "Publication #2"
end
