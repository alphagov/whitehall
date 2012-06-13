Given /^a submitted policy titled "([^"]*)"$/ do |policy_title|
  create(:submitted_policy, title: policy_title)
end

Given /^I am on the policies admin page$/ do
  visit admin_editions_path
end

Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am a writer called "#{author}"}

  begin_drafting_policy title: title, body: body
  click_button 'Save'

  click_button 'Submit to 2nd pair of eyes'
end

Given /^a published policy "([^"]*)" that appears in the "([^"]*)" and "([^"]*)" policy topics$/ do |policy_title, policy_topic_1, policy_topic_2|
  policy = create(:published_policy, title: policy_title)
  create(:policy_topic, name: policy_topic_1, policies: [policy])
  create(:policy_topic, name: policy_topic_2, policies: [policy])
end

Given /^a published policy "([^"]*)" that does not apply to the nations:$/ do |policy_title, nation_names|
  policy = create(:published_policy, title: policy_title)
  nation_names.raw.flatten.each do |nation_name|
    policy.inapplicable_nations << Nation.find_by_name!(nation_name)
  end
end

Given /^I visit the list of draft policies$/ do
  visit admin_editions_path(state: :draft)
end

Given /^I click on the policy "([^"]*)"$/ do |policy_title|
  click_link policy_title
end

Given /^I start editing the policy "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
end

Given /^a published policy "([^"]*)" with related published publications "([^"]*)" and "([^"]*)"$/ do |policy_title, publication_title_1, publication_title_2|
  policy = create(:published_policy, title: policy_title)
  publication_1 = create(:published_publication, title: publication_title_1, related_policies: [policy])
  publication_2 = create(:published_publication, title: publication_title_2, related_policies: [policy])
end

Given /^a published policy "([^"]*)" with related published consultations "([^"]*)" and "([^"]*)"$/ do |policy_title, consultation_title_1, consultation_title_2|
  policy = create(:published_policy, title: policy_title)
  consultation_1 = create(:published_consultation, title: consultation_title_1, related_policies: [policy])
  consultation_2 = create(:published_consultation, title: consultation_title_2, related_policies: [policy])
end

Given /^a published policy "([^"]*)" with related published news articles "([^"]*)" and "([^"]*)"$/ do |policy_title, news_article_title_1, news_article_title_2|
  policy = create(:published_policy, title: policy_title)
  news_article_1 = create(:published_news_article, title: news_article_title_1, related_policies: [policy])
  news_article_2 = create(:published_news_article, title: news_article_title_2, related_policies: [policy])
end

Given /^two published policies "([^"]*)" and "([^"]*)" exist$/ do |policy_title_1, policy_title_2|
  create(:published_policy, title: policy_title_1)
  create(:published_policy, title: policy_title_2)
end

Given /^a published policy "([^"]*)" with related draft publication "([^"]*)"$/ do |policy_title, publication_title|
  policy = create(:published_policy, title: policy_title)
  create(:draft_publication, title: publication_title, related_policies: [policy])
end

Given /^"([^"]*)" has received an email requesting they fact check a draft policy "([^"]*)" with supporting page "([^"]*)"$/ do |email, title, supporting_page_title|
  policy = create(:draft_policy, title: title)
  supporting_page = create(:supporting_page, edition: policy, title: supporting_page_title)
  fact_check_request = create(:fact_check_request, edition: policy, email_address: email)
  Notifications.fact_check_request(fact_check_request, host: "example.com").deliver
end

Given /^an editor named "([^"]*)" has rejected the policy titled "([^"]*)"$/ do |editor_name, policy_title|
  editor = create(:departmental_editor, name: editor_name)
  policy = create(:submitted_policy, title: policy_title)
  login_as editor
  policy.reject!
end

Given /^a published (publication|consultation|news article|speech) "([^"]*)" related to the policy "([^"]*)"$/ do |document_type, document_title, policy_title|
  policy = Policy.find_by_title!(policy_title)
  create("published_#{document_class(document_type).name.underscore}".to_sym,
          title: document_title, related_policies: [policy])
end

When /^I reject the policy titled "([^"]*)"$/ do |policy_title|
  policy = Policy.find_by_title(policy_title)
  visit admin_policy_path(policy)
  click_button "Reject"
  fill_in "Remark", with: "reason-for-rejection"
  click_button "Submit remark"
end

When /^I create a new edition of the published policy "([^"]*)"$/ do |policy_title|
  visit admin_editions_path(state: :published)
  click_link policy_title
  click_button 'Create new edition'
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
  policy = Policy.find_by_title!(title)
  visit admin_editions_path(state: :draft)
  within(record_css_selector(policy)) do
    click_link title
  end
  within("#new_fact_check_request") do
    fill_in "Email address", with: email
    fill_in "Extra instructions", with: instructions
    click_button "Send request"
  end
end

When /^I draft a new policy "([^"]*)"$/ do |title|
  begin_drafting_policy title: title
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" in the "([^"]*)" and "([^"]*)" policy topics$/ do |title, first_policy_topic, second_policy_topic|
  begin_drafting_policy title: title
  select first_policy_topic, from: "Policy topics"
  select second_policy_topic, from: "Policy topics"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" produced by the "([^"]*)" and "([^"]*)" organisations$/ do |title, first_org, second_org|
  begin_drafting_policy title: title
  select first_org, from: "Organisations"
  select second_org, from: "Organisations"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" associated with "([^"]*)" and "([^"]*)"$/ do |title, minister_1, minister_2|
  begin_drafting_policy title: title
  select minister_1, from: "Ministerial roles"
  select minister_2, from: "Ministerial roles"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" that does not apply to the nations:$/ do |title, nations|
  begin_drafting_policy title: title
  nations.raw.flatten.each do |nation_name|
    check nation_name
    fill_in "Alternative url", with: "http://www.#{nation_name}.com/"
  end
  click_button "Save"
end

When /^I edit the policy "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
  fill_in_change_note_if_required
  click_button "Save"
end

When /^I edit the policy "([^"]*)" adding it to the "([^"]*)" policy topic$/ do |title, policy_topic_name|
  begin_editing_document title
  select policy_topic_name, from: "Policy topics"
  fill_in_change_note_if_required
  click_button "Save"
end

When /^I publish the policy "([^"]*)" but another user edits it while I am viewing it$/ do |title|
  policy = Policy.find_by_title!(title)
  visit_document_preview title
  policy.update_attributes!(body: 'A new body')
  publish(ignore_errors: true)
end

When /^I publish the policy "([^"]*)" without a change note$/ do |title|
  policy = Policy.find_by_title!(title)
  visit_document_preview title
  publish(without_change_note: true)
end

When /^I visit the published policy "([^"]*)"$/ do |title|
  policy = Policy.published.find_by_title!(title)
  visit public_document_path(policy)
end

When /^I delete the draft policy "([^"]*)"$/ do |title|
  policy = Policy.draft.find_by_title!(title)
  visit admin_edition_path(policy)
  click_button "Delete"
end

When /^I view the policy titled "([^"]*)"$/ do |policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
end

When /^I resubmit the policy titled "([^"]*)"$/ do |policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_button "Submit to 2nd pair of eyes"
end

When /^I publish a new edition of the policy "([^"]*)" with the new title "([^"]*)"$/ do |policy_title, new_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_button "Create new edition"
  fill_in "Title", with: new_title
  fill_in_change_note_if_required
  click_button "Save"
  publish(force: true)
end

When /^I publish a new edition of the policy "([^"]*)" without a change note$/ do |policy_title|
  policy = Policy.latest_edition.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_button "Create new edition"
  click_button "Save"
  publish(force: true, ignore_errors: true)
end

When /^I publish a new edition of the policy "([^"]*)" as a minor change$/ do |policy_title|
  policy = Policy.latest_edition.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_button "Create new edition"
  check "Minor change"
  click_button "Save"
  publish(force: true, ignore_errors: true)
end

When /^I publish a new edition of the policy "([^"]*)" with a change note "([^"]*)"$/ do |policy_title, change_note|
  policy = Policy.latest_edition.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_button "Create new edition"
  fill_in "Change note", with: change_note
  click_button "Save"
  publish(force: true)
end

Then /^I should see the fact checking feedback "([^"]*)"$/ do |comments|
  assert page.has_css?(".fact_check_request .comments", text: comments)
end

Then /^I should see the pending fact check request to "([^"]*)" for policy "([^"]*)"$/ do |email_address, title|
  visit admin_policy_path(Policy.find_by_title!(title))
  assert page.has_css?(".fact_check_request.pending .from", text: email_address)
end

Then /^the published policy "([^"]*)" should remain unchanged$/ do |policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit public_document_path(policy)
  assert page.has_css?('.page_title', text: policy.title)
  assert page.has_css?('.document .body', text: policy.body)
end

Then /^I should see that those responsible for the policy are:$/ do |table|
  table.hashes.each do |row|
    person = find_person(row["Person"])
    assert page.has_css?(".minister", text: person.name)
  end
end

Then /^I should see that the policy is written by "([^"]*)"$/ do |name|
  assert page.has_css?(".document .authors", text: name)
end

Then /^I should see that "([^"]*)" is the policy body$/ do |policy_body|
  assert page.has_css?(".document .body", text: policy_body)
end

Then /^I should see that the policy does not apply to:$/ do |nation_names|
  message = "This policy does not apply to #{nation_names.raw.flatten.sort.to_sentence}."
  assert page.has_css?("#{inapplicable_nations_selector} p", text: message)
end

Then /^I should not see "([^"]*)" from the "([^"]*)" policy$/ do |publication_title, policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit public_document_path(policy)
  refute has_css?("#related-documents .publication a", text: publication_title)
end

Then /^they should see the draft policy "([^"]*)"$/ do |title|
  policy = Policy.draft.find_by_title!(title)
  assert page.has_css?('.document .title', text: policy.title)
  assert page.has_css?('.document .body', text: policy.body)
end

Then /^they should see the supporting page "([^"]*)"$/ do |title|
  supporting_page = SupportingPage.find_by_title!(title)
  assert page.has_css?("#{supporting_pages_selector} .document .title", text: supporting_page.title)
  assert page.has_css?("#{supporting_pages_selector} .document .body", text: supporting_page.body)
end

Then /^I can see links to the related published policies "([^"]*)" and "([^"]*)"$/ do |policy_title_1, policy_title_2|
  assert has_css?("#related-policies .policy a", text: policy_title_1)
  assert has_css?("#related-policies .policy a", text: policy_title_2)
end

Then /^I can see links to the related published speech "([^"]*)"$/ do |speech_title|
  assert has_css?("#related-speeches .speech a", text: speech_title)
end

Then /^I should see a link to the public version of the policy "([^"]*)"$/ do |policy_title|
  policy = Policy.published.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  assert has_css?(".actions .public_version a", href: public_document_path(policy)), "Link to public version of policy not found"
end

Then /^I should see the policy titled "([^"]*)" in the list of documents that need work$/ do |policy_title|
  visit admin_editions_path
  click_link "Show only rejected documents"
  policy = Policy.find_by_title(policy_title)
  assert page.has_css?("#{record_css_selector(policy)}", text: policy.title)
end

Then /^the writers who worked on the policy titled "([^"]*)" should be emailed about the rejection$/ do |policy_title|
  policy = Policy.find_by_title(policy_title)
  policy.authors.each do |writer|
    assert_equal 1, unread_emails_for(writer.email).size
    assert_match /The policy '#{policy_title}' was rejected by/, unread_emails_for(writer.email).first.subject
  end
end

Then /^the writers who worked on the policy titled "([^"]*)" should be emailed about the publication$/ do |policy_title|
  policy = Policy.find_by_title(policy_title)
  policy.authors.each do |writer|
    assert_equal 1, unread_emails_for(writer.email).size
    assert_match /The policy '#{policy_title}' has been published/, unread_emails_for(writer.email).first.subject
  end
end

Then /^I should see that it was rejected by "([^"]*)"$/ do |rejected_by|
  assert page.has_css?('.rejected_by', text: rejected_by)
end

Then /^I should see the policy titled "([^"]*)" in the list of submitted documents$/ do |policy_title|
  visit admin_editions_path(state: :draft)
  click_link "Show only submitted documents"
  policy = Policy.find_by_title!(policy_title)
  assert page.has_css?("#{record_css_selector(policy)}", text: policy.title)
end

Then /^I can see links to the recently changed document "([^"]*)"$/ do |title|
  edition = Edition.find_by_title!(title)
  assert page.has_css?("#recently-changed #{record_css_selector(edition)} a", text: edition.title), "#{edition.title} not found"
end

Then /^the change note "([^"]*)" should appear in the history for the policy "([^"]*)"$/ do |change_note, title|
  click_link title
  assert page.has_css?(".change_notes", text: Regexp.new(change_note))
end
