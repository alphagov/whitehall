Given /^I am on the policies admin page$/ do
  visit admin_documents_path
end

Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am a writer called "#{author}"}
  And %{I visit the new policy page}
  And %{I write and save a policy "#{title}" with body "#{body}"}
  And %{I submit the policy for the second set of eyes}
end

Given /^a published policy "([^"]*)" that appears in the "([^"]*)" and "([^"]*)" topics$/ do |policy_title, topic_1, topic_2|
  document = create(:published_policy, title: policy_title)
  create(:topic, name: topic_1, documents: [document])
  create(:topic, name: topic_2, documents: [document])
end

Given /^a published policy "([^"]*)" that does not apply to the nations:$/ do |policy_title, nation_names|
  policy = create(:published_policy, title: policy_title)
  nation_names.raw.flatten.each do |nation_name|
    policy.inapplicable_nations << Nation.find_by_name!(nation_name)
  end
end

Given /^I visit the list of draft policies$/ do
  visit admin_documents_path
end

Given /^I click on the policy "([^"]*)"$/ do |policy_title|
  click_link policy_title
end

Given /^I submit the policy for the second set of eyes$/ do
  click_button 'Submit to 2nd pair of eyes'
end

Given /^a published policy exists$/ do
  @document = create(:published_policy)
end

Given /^I start editing the policy "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
end

Given /^a published policy "([^"]*)" with related published publications "([^"]*)" and "([^"]*)"$/ do |policy_title, publication_title_1, publication_title_2|
  publication_1 = create(:published_publication, title: publication_title_1)
  publication_2 = create(:published_publication, title: publication_title_2)

  policy = create(:published_policy, title: policy_title, documents_related_with: [publication_1, publication_2])
end

Given /^a published policy "([^"]*)" with related published consultations "([^"]*)" and "([^"]*)"$/ do |policy_title, consultation_title_1, consultation_title_2|
  consultation_1 = create(:published_consultation, title: consultation_title_1)
  consultation_2 = create(:published_consultation, title: consultation_title_2)

  policy = create(:published_policy, title: policy_title, documents_related_with: [consultation_1, consultation_2])
end

Given /^a published policy "([^"]*)" with related published news articles "([^"]*)" and "([^"]*)"$/ do |policy_title, news_article_title_1, news_article_title_2|
  news_article_1 = create(:published_news_article, title: news_article_title_1)
  news_article_2 = create(:published_news_article, title: news_article_title_2)

  policy = create(:published_policy, title: policy_title, documents_related_with: [news_article_1, news_article_2])
end

Given /^two published policies "([^"]*)" and "([^"]*)" exist$/ do |policy_title_1, policy_title_2|
  create(:published_policy, title: policy_title_1)
  create(:published_policy, title: policy_title_2)
end

Given /^a published policy "([^"]*)" with related draft publication "([^"]*)"$/ do |policy_title, publication_title|
  create(:published_policy, title: policy_title, documents_related_with: [create(:draft_publication, title: publication_title)])
end

Given /^"([^"]*)" has received an email requesting they fact check a draft policy "([^"]*)" with supporting document "([^"]*)"$/ do |email, title, supporting_document_title|
  policy = create(:draft_policy, title: title)
  supporting_document = create(:supporting_document, document: policy, title: supporting_document_title)
  fact_check_request = create(:fact_check_request, document: policy, email_address: email)
  Notifications.fact_check(fact_check_request, host: "example.com").deliver
end

When /^I create a new edition of the published policy$/ do
  visit published_admin_documents_path
  click_link Policy.published.last.title
  click_button 'Create new draft'
end

When /^I edit the new edition$/ do
  fill_in 'Title', with: "New title"
  fill_in 'Body', with: "New policy"
  click_button 'Save'
end

When /^I visit the new policy page$/ do
  visit new_admin_policy_path
end

When /^I request that "([^"]*)" fact checks the policy "([^"]*)" with instructions "([^"]*)"$/ do |email, title, instructions|
  document = Policy.find_by_title!(title)
  visit admin_documents_path
  within(record_css_selector(document)) do
    click_link title
  end
  within("#new_fact_check_request") do
    fill_in "Email address", with: email
    fill_in "Extra instructions", with: instructions
    click_button "Send request"
  end
end

When /^I write and save a policy "([^"]*)" with body "([^"]*)"$/ do |title, body|
  When %{I write a policy "#{title}" with body "#{body}"}
  click_button 'Save'
end

When /^I write a policy "([^"]*)" with body "([^"]*)"$/ do |title, body|
  fill_in 'Title', with: title
  fill_in 'Body', with: body
end

When /^I draft a new policy "([^"]*)" in the "([^"]*)" and "([^"]*)" topics$/ do |title, first_topic, second_topic|
  begin_drafting_document type: "Policy", title: title
  select first_topic, from: "Topics"
  select second_topic, from: "Topics"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" in the "([^"]*)" and "([^"]*)" organisations$/ do |title, first_org, second_org|
  begin_drafting_document type: "Policy", title: title
  select first_org, from: "Organisations"
  select second_org, from: "Organisations"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" associated with "([^"]*)" and "([^"]*)"$/ do |title, minister_1, minister_2|
  begin_drafting_document type: "Policy", title: title
  select minister_1, from: "Ministers"
  select minister_2, from: "Ministers"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" that does not apply to the nations:$/ do |title, nations|
  begin_drafting_document type: "Policy", title: title
  nations.raw.flatten.each do |nation_name|
    check nation_name
    fill_in "Alternative url", with: "http://www.#{nation_name}.com/"
  end
  click_button "Save"
end

When /^I edit the policy "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I edit the policy "([^"]*)" adding it to the "([^"]*)" topic$/ do |title, topic_name|
  begin_editing_document title
  select topic_name, from: "Topics"
  click_button "Save"
end

When /^I publish the policy "([^"]*)" but another user edits it while I am viewing it$/ do |title|
  document = Policy.find_by_title!(title)
  visit_document_preview title
  document.update_attributes!(body: 'A new body')
  click_button "Publish"
end

When /^I visit the published policy "([^"]*)"$/ do |title|
  policy = Policy.published.find_by_title!(title)
  visit public_document_path(policy)
end

When /^I delete the draft policy "([^"]*)"$/ do |title|
  policy = Policy.draft.find_by_title!(title)
  visit admin_document_path(policy)
  click_button "Delete"
end

Then /^I should see the fact checking feedback "([^"]*)"$/ do |comments|
  assert page.has_css?(".fact_check_request .comments", text: comments)
end

Then /^I should see the pending fact check request to "([^"]*)" for policy "([^"]*)"$/ do |email_address, title|
  visit admin_policy_path(Policy.find_by_title!(title))
  assert page.has_css?(".fact_check_request.pending .from", text: email_address)
end

Then /^the published policy should remain unchanged$/ do
  visit public_document_path(@document)
  assert page.has_css?('.document_view .title', text: @document.title)
  assert page.has_css?('.document_view .body', text: @document.body)
end

Then /^I should see that those responsible for the policy are:$/ do |table|
  table.hashes.each do |row|
    person = Person.find_by_name!(row["Person"])
    ministerial_role = person.ministerial_roles.find_by_name!(row["Ministerial Role"])
    assert page.has_css?(".ministerial_role", text: ministerial_role.to_s)
  end
end

Then /^I should see that "([^"]*)" is the policy author$/ do |name|
  assert page.has_css?(".document_view .author", text: name)
end

Then /^I should see that "([^"]*)" is the policy body$/ do |policy_body|
  assert page.has_css?(".document_view .body", text: policy_body)
end

Then /^I should see that the policy does not apply to:$/ do |nation_names|
  message = "This policy does not apply to #{nation_names.raw.flatten.sort.to_sentence}."
  assert page.has_css?("#inapplicable_nations p", text: message)
end

Then /^I should not see "([^"]*)" from the "([^"]*)" policy$/ do |publication_title, policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit public_document_path(policy)
  refute has_css?("#related-documents .publication a", text: publication_title)
end

Then /^they should see the draft policy "([^"]*)"$/ do |title|
  policy = Policy.draft.find_by_title!(title)
  assert page.has_css?('.document_view .title', text: policy.title)
  assert page.has_css?('.document_view .body', text: policy.body)
end

Then /^they should see the supporting document "([^"]*)"$/ do |title|
  supporting_document = SupportingDocument.find_by_title!(title)
  assert page.has_css?('#supporting_documents .document_view .title', text: supporting_document.title)
  assert page.has_css?('#supporting_documents .document_view .body', text: supporting_document.body)
end

Then /^I can see links to the related published policies "([^"]*)" and "([^"]*)"$/ do |policy_title_1, policy_title_2|
  assert has_css?("#related-policies .policy a", text: policy_title_1)
  assert has_css?("#related-policies .policy a", text: policy_title_2)
end

Then /^I should see a link to the public version of the policy "([^"]*)"$/ do |policy_title|
  policy = Policy.published.find_by_title!(policy_title)
  visit admin_document_path(policy)
  assert has_css?(".actions .public_version a", href: public_document_path(policy)), "Link to public version of policy not found"
end
