Given /^a published news article "([^"]*)" with related published policies "([^"]*)" and "([^"]*)"$/ do |news_article_title, policy_title_1, policy_title_2|
  policy_1 = create(:published_policy, title: policy_title_1)
  policy_2 = create(:published_policy, title: policy_title_2)
  create(:published_news_article, title: news_article_title, related_editions: [policy_1, policy_2])
end

Given /^a published news article "([^"]*)" for the organisation "([^"]*)"$/ do |title, organisation|
  organisation = create(:organisation, name: organisation)
  create(:published_news_article, title: title, organisations: [organisation])
end

Given /^a published news article "([^"]*)" for the policy "([^"]*)"$/ do |title, policy_name|
  policy = Policy.find_by_title(policy_name) || create(:policy, title: policy_name)
  create(:published_news_article, title: title, related_editions: [policy])
end

Given /^a published news article "([^"]*)" associated with "([^"]*)"$/ do |title, appointee|
  person = find_person(appointee)
  appointment = find_person(appointee).current_role_appointments.last
  create(:published_news_article, title: title, role_appointments: [appointment])
end

Given /^a published news article "([^"]*)" which isn't explicitly associated with "([^"]*)"$/ do |title, thing|
  create(:published_news_article, title: title)
end

When /^I draft a new news article "([^"]*)"$/ do |title|
  begin_drafting_news_article title: title, summary: "here's a simple summary"
  within ".images" do
    attach_file "File", jpg_image
    fill_in "Alt text", with: 'An alternative description'
  end
  click_button "Save"
end

When /^I draft a new news article "([^"]*)" relating it to the policies "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_news_article title: title
  select first_policy, from: "Related policies"
  select second_policy, from: "Related policies"
  click_button "Save"
end

When /^I draft a new news article "([^"]*)" relating it to the worldwide_priorities "([^"]*)" and "([^"]*)"$/ do |title, first_priority, second_priority|
  begin_drafting_news_article title: title
  select first_priority, from: "Worldwide priorities"
  select second_priority, from: "Worldwide priorities"
  click_button "Save"
end

When /^I publish a news article "([^"]*)" associated with "([^"]*)"$/ do |title, person_name|
  begin_drafting_news_article title: title
  select person_name, from: "Ministers"
  click_button "Save"
  publish force: true
end

When /^I attempt to add the article image into the markdown$/ do
  fill_in "Body", with: "body copy\n!!1\nmore body"
end

Then /^the news story "([^"]*)" should have been created$/ do |title|
  refute NewsArticle.find_by_title(title).nil?
end

Then /^the article mentions "([^"]*)" and links to their bio page$/ do |person_name|
  visit document_path(NewsArticle.last)
  assert has_css?("a.person[href*='#{person_path(find_person(person_name))}']", text: person_name)
end

Then /^the news article tag is the same as the person in the text$/ do
  visit admin_edition_path(NewsArticle.last)
  click_button "Create new edition"
  appointment = NewsArticle.last.role_appointments.first
  assert has_css?("select#edition_role_appointment_ids option[value='#{appointment.id}'][selected=selected]")
end

Then /^I should see both the news articles for the Deputy Prime Minister role$/ do
  assert has_css?(".news_article", text: "News from Don, Deputy PM")
  assert has_css?(".news_article", text: "News from Harriet, Deputy PM")
end

Then /^I should see both the news articles for Harriet Home$/ do
  assert has_css?(".news_article", text: "News from Harriet, Deputy PM")
  assert has_css?(".news_article", text: "News from Harriet, Home Sec")
end

Then /^I should be informed I shouldn't use this image in the markdown$/ do
  click_on "Edit"
  assert has_no_css?("fieldset#image_fields .image input[value='!!1']")
end

Then /^I should see the first uploaded image used as the lead image$/ do
  article = NewsArticle.last
  publish force: true
  visit document_path(article)
  assert page.has_css?("aside.sidebar img[src*='#{article.images.first.url(:s300)}']")
end

Then /^if no image is uploaded a default image is shown$/ do
  article = NewsArticle.last
  article.images.first.destroy
  visit document_path(article)
  assert page.has_css?("aside.sidebar img[src*='placeholder']")
end

When /^I browse to the announcements index$/ do
  visit announcements_path
end
