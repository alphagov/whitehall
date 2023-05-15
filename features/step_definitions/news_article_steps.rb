When(/^I draft a new news article "([^"]*)"$/) do |title|
  begin_drafting_news_article title:, summary: "here's a simple summary"
  click_button "Save"
end

And(/^when I publish the article$/) do
  stub_publishing_api_links_with_taxons(@news_article.content_id, %w[a-taxon-content-id])
  visit admin_edition_path(@news_article)
  publish(force: true)
end

When(/^I draft a valid news article of type "([^"]*)" with title "([^"]*)"$/) do |news_type, title|
  if news_type == "World news story"
    create(:worldwide_organisation, name: "Afghanistan embassy")
    create(:world_location, name: "Afghanistan", active: true)
    begin_drafting_news_article(title:, first_published: Time.zone.today.to_s, announcement_type: news_type)
    select "Afghanistan embassy", from: using_design_system? ? "Worldwide organisations" : "Select the worldwide organisations associated with this news article"
    select "Afghanistan", from: using_design_system? ? "World locations" : "Select the world locations this news article is about"
    select "", from: "edition_lead_organisation_ids_1"
  else
    begin_drafting_news_article(title:, first_published: Time.zone.today.to_s, announcement_type: news_type)
  end

  click_button "Save"
end

Then(/^the news article "([^"]*)" should have been created$/) do |title|
  @news_article = NewsArticle.find_by(title:)
  expect(@news_article).to be_present
end

Then("I subsequently change the primary locale") do
  visit admin_edition_path(@news_article)
  click_button "Create new edition"
  select "Deutsch (German)", from: "edition[primary_locale]"
  choose "No – it’s a minor edit that does not change the meaning"
  click_button "Save"
end

Then("there should exist only one translation") do
  expect(%w[published draft]).to eq(@news_article.document.editions.pluck(:state))
  expect(1).to eq(@news_article.document.latest_edition.translations.count)
end
