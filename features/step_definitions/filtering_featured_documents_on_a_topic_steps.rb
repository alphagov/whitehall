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
  page.click_on "Reset all fields"
end

When(/^I filter by title$/) do
  page.fill_in "Title or slug", with: "publication"
  page.click_on "Search"
end

When(/^I filter by author$/) do
  page.select @news.authors.first.name, from: "Author"
  page.click_on "Search"
end

When(/^I filter by organisation$/) do
  page.select "A Department", from: "organisation"
  page.click_on "Search"
end

When(/^I filter by document type$/) do
  page.select "News articles", from: "Document type"
  page.click_on "Search"
end

Then(/^I see documents with that title$/) do
  assert page.has_content?("Publication #1")
  assert page.has_content?("Publication #2")

  assert page.has_no_content?("News #1")
  assert page.has_no_content?("News #2")
end

Then(/^I see documents by that author$/) do
  assert page.has_content?("News #2")

  assert page.has_no_content?("Publication #1")
  assert page.has_no_content?("Publication #2")
  assert page.has_no_content?("News #1")
end

Then(/^I see documents with that organisation$/) do
  assert page.has_content?("Publication #2")

  assert page.has_no_content?("Publication #1")
  assert page.has_no_content?("News #1")
  assert page.has_no_content?("News #2")
end

Then(/^I see documents with that document type$/) do
  assert page.has_content?("News #1")
  assert page.has_content?("News #2")

  assert page.has_no_content?("Publication #1")
  assert page.has_no_content?("Publication #2")
end
