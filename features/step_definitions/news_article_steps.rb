Given(/^a published news article "([^"]*)" associated with "([^"]*)"$/) do |title, appointee|
  appointment = find_person(appointee).current_role_appointments.last
  news_article = create(:published_news_article, title: title, role_appointments: [appointment])

  stub_any_search.to_return(
    body: {
      results: [
        { link: document_path(news_article), title: news_article.title },
      ],
    }.to_json,
  )
end

When(/^I draft a new news article "([^"]*)"$/) do |title|
  begin_drafting_news_article title: title, summary: "here's a simple summary"
  within ".images" do
    attach_file "File", jpg_image, match: :first
    fill_in "Alt text", with: "An alternative description", match: :first
  end
  click_button "Save"
end

When(/^I draft a French\-only "World news story" news article associated with "([^"]*)"$/) do |location_name|
  create(:worldwide_organisation, name: "French embassy")

  begin_drafting_news_article title: "French-only news article", body: "test-body", summary: "test-summary", announcement_type: "World news story"
  select "Français", from: "Document language"
  select location_name, from: "Select the world locations this news article is about"
  select "French embassy", from: "Select the worldwide organisations associated with this news article"
  select "", from: "edition_lead_organisation_ids_1"
  click_button "Save and continue"
  click_button "Save topic changes"
  @news_article = find_news_article_in_locale!(:fr, "French-only news article")
end

And(/^when I publish the article$/) do
  stub_publishing_api_links_with_taxons(@news_article.content_id, %w[a-taxon-content-id])
  visit admin_edition_path(@news_article)
  publish(force: true)
end

Then(/^I should see the news article listed in admin with an indication that it is in French$/) do
  assert_path admin_edition_path(@news_article)
  assert_text "This document is French-only"
end

Then(/^I should only see the news article on the French version of the public "([^"]*)" location page$/) do |world_location_name|
  world_location = WorldLocation.find_by!(name: world_location_name)
  visit world_location_path(world_location, locale: :fr)
  within record_css_selector(@news_article) do
    assert_text @news_article.title
  end
  visit world_location_path(world_location)
  assert_no_selector record_css_selector(@news_article)
end

When(/^I draft a valid news article of type "([^"]*)" with title "([^"]*)"$/) do |news_type, title|
  if news_type == "World news story"
    create(:worldwide_organisation, name: "Afghanistan embassy")
    create(:world_location, name: "Afghanistan", active: true)
    begin_drafting_news_article(title: title, first_published: Time.zone.today.to_s, announcement_type: news_type)
    select "Afghanistan embassy", from: "Select the worldwide organisations associated with this news article"
    select "Afghanistan", from: "Select the world locations this news article is about"
    select "", from: "edition_lead_organisation_ids_1"
  else
    begin_drafting_news_article(title: title, first_published: Time.zone.today.to_s, announcement_type: news_type)
  end

  click_button "Save"
end

Then(/^the news article "([^"]*)" should have been created$/) do |title|
  @news_article = NewsArticle.find_by(title: title)
  refute @news_article.nil?
end

Then("I subsequently change the primary locale") do
  visit admin_edition_path(@news_article)
  click_button "Create new edition to edit"
  select "Deutsch (German)", from: "edition[primary_locale]"
  choose "edition_minor_change_true"
  click_button "Save and continue"
  click_button "Save topic changes"
end

Then("there should exist only one translation") do
  assert_equal %w[published draft], @news_article.document.editions.pluck(:state)
  assert_equal 1, @news_article.document.latest_edition.translations.count
end
