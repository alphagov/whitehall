Given /^a published news article "([^"]*)" with related published policies "([^"]*)" and "([^"]*)"$/ do |news_article_title, policy_title_1, policy_title_2|
  policy_1 = create(:published_policy, title: policy_title_1)
  policy_2 = create(:published_policy, title: policy_title_2)
  create(:published_news_article, title: news_article_title, related_policies: [policy_1, policy_2])
end

Given /^a published news article "([^"]*)" with notes to editors "([^"]*)"$/ do |title, notes_to_editors|
  create(:published_news_article, title: title, notes_to_editors: notes_to_editors)
end

Given /^a published news article "([^"]*)" for the organisation "([^"]*)"$/ do |title, organisation|
  organisation = create(:organisation, name: organisation)
  create(:published_news_article, title: title, organisations: [organisation])
end

Given /^a published news article "([^"]*)" for the policy "([^"]*)"$/ do |title, policy_name|
  policy = Policy.find_by_title(policy_name) || create(:policy, title: policy_name)
  create(:published_news_article, title: title, related_policies: [policy])
end


Given /^a published news article "([^"]*)" associated with "([^"]*)"$/ do |title, appointee|
  person = find_person(appointee)
  appointment = find_person(appointee).current_role_appointments.last
  create(:published_news_article, title: title, role_appointments: [appointment])
end

When /^I draft a new news article "([^"]*)"$/ do |title|
  begin_drafting_document type: "news_article", title: title
  fill_in "Summary", with: "here's a simple summary"
  within ".images" do
    attach_file "File", Rails.root.join("features/fixtures/portas-review.jpg")
    fill_in "Alt text", with: 'An alternative description'
  end
  click_button "Save"
end

When /^I draft a new news article "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "News Article", title: title
  select first_policy, from: "Related policies"
  select second_policy, from: "Related policies"
  click_button "Save"
end

Then /^I should see the notes to editors "([^"]*)" for the news article$/ do |notes_to_editors|
  assert has_css?("#{notes_to_editors_selector}", text: notes_to_editors)
end

When /^I publish a news article "([^"]*)" associated with "([^"]*)"$/ do |title, person_name|
  begin_drafting_document type: "News Article", title: title
  select person_name, from: "Ministers"
  click_button "Save"
  click_button "Force Publish"
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
